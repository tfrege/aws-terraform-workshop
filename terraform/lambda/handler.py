import json
import os
import random
from datetime import datetime, timezone, timedelta

import boto3

#s3 = boto3.client("s3")
#sns = boto3.client("sns")

#ARTIFACT_BUCKET = os.environ["ARTIFACT_BUCKET"]
#ARTIFACT_PREFIX = os.environ.get("ARTIFACT_PREFIX", "launch-window")
#DONE_TOPIC_ARN = os.environ["DONE_TOPIC_ARN"]

MAX_WIND_KTS = float(os.environ.get("MAX_WIND_KTS", "20"))
MIN_CLOUD_CEILING_FT = float(os.environ.get("MIN_CLOUD_CEILING_FT", "2500"))
LIGHTNING_ALLOWED = os.environ.get("LIGHTNING_ALLOWED", "false").lower() == "true"
RANGE_ALLOWED = os.environ.get("RANGE_ALLOWED", "GREEN")

RANGE_STATUSES = ["GREEN", "YELLOW", "RED"]

def _utc_now():
    return datetime.now(timezone.utc)

def _parse_sns_from_sqs_record(record: dict) -> dict:
    """
    SQS record body contains an SNS envelope JSON string when you subscribe SQS to SNS.
    We unwrap it and return the decoded SNS Message as dict (if JSON), else as {"raw": "..."}.
    """
    body = record.get("body", "")
    envelope = json.loads(body)
    msg_str = envelope.get("Message", "")
    try:
        return json.loads(msg_str)
    except Exception:
        return {"raw": msg_str}

def _simulate_constraints():
    # Simple, believable ranges for demo
    return {
        "wind_speed_kts": round(random.uniform(0, 30), 1),
        "cloud_ceiling_ft": int(random.uniform(500, 10000)),
        "lightning_risk": random.choice([True, False, False]),  # bias to False
        "range_status": random.choice(RANGE_STATUSES),
    }

def _evaluate(constraints: dict):
    reasons = []
    if constraints["wind_speed_kts"] > MAX_WIND_KTS:
        reasons.append(f"Wind {constraints['wind_speed_kts']}kts > max {MAX_WIND_KTS}kts")
    if constraints["cloud_ceiling_ft"] < MIN_CLOUD_CEILING_FT:
        reasons.append(f"Cloud ceiling {constraints['cloud_ceiling_ft']}ft < min {MIN_CLOUD_CEILING_FT}ft")
    if (not LIGHTNING_ALLOWED) and constraints["lightning_risk"]:
        reasons.append("Lightning risk is TRUE and lightning is not allowed")
    if constraints["range_status"] != RANGE_ALLOWED:
        reasons.append(f"Range status {constraints['range_status']} != allowed {RANGE_ALLOWED}")

    decision = "GO" if not reasons else "NO-GO"
    return decision, reasons

# def _artifact_key(run_dt: datetime, mission: str):
#      # launch-window/YYYY/MM/DD/HHMMSSZ/mission=<mission>/launch_window_report.json
#     ts_folder = run_dt.strftime("%Y/%m/%d/%H%M%SZ")
#     safe_mission = "".join(c if c.isalnum() or c in "-_." else "_" for c in mission)
#     return f"{ARTIFACT_PREFIX}/{ts_folder}/mission={safe_mission}/launch_window_report.json"

def lambda_handler(event, context):
    """
    Handles batched SQS events. Each record corresponds to a publish from SNS ingest topic.
    """
    run_dt = _utc_now()
    published = 0

    mission = "DEMO-1"
    launch_site = "KSC"
    vehicle = "LV-A"

    # Create a demo window (next 2 hours)
    window_start = run_dt.replace(minute=0, second=0, microsecond=0) + timedelta(hours=1)
    window_end = window_start + timedelta(hours=2)

    constraints = _simulate_constraints()
    decision, reasons = _evaluate(constraints)

    report = {
        "run_id": run_dt.isoformat(),
        "mission": mission,
        "launch_site": launch_site,
        "vehicle": vehicle,
        "window": {
            "start_utc": window_start.isoformat(),
            "end_utc": window_end.isoformat(),
        },
        "constraints": constraints,
        "thresholds": {
            "max_wind_kts": MAX_WIND_KTS,
            "min_cloud_ceiling_ft": MIN_CLOUD_CEILING_FT,
            "lightning_allowed": LIGHTNING_ALLOWED,
            "range_allowed": RANGE_ALLOWED,
        },
        "decision": decision,
        "reasons": reasons,
    }

    # key = _artifact_key(run_dt, mission)
    # s3.put_object(
    #     Bucket=ARTIFACT_BUCKET,
    #     Key=key,
    #     Body=json.dumps(report, indent=2).encode("utf-8"),
    #     ContentType="application/json",
    # )

    subject = f"Launch Window Check Complete — {mission}"
    body_lines = [
        f"Decision: {decision}",
        f"Mission: {mission}",
        f"Site: {launch_site}",
        f"Vehicle: {vehicle}",
        f"Wind: {constraints['wind_speed_kts']} kts (max {MAX_WIND_KTS})",
        f"Cloud ceiling: {constraints['cloud_ceiling_ft']} ft (min {MIN_CLOUD_CEILING_FT})",
        f"Lightning risk: {constraints['lightning_risk']} (allowed {LIGHTNING_ALLOWED})",
        f"Range status: {constraints['range_status']} (allowed {RANGE_ALLOWED})",
    ]
    
    # if reasons:
    #     body_lines.append("")
    #     body_lines.append("NO-GO reasons:")
    #     body_lines.extend([f"- {r}" for r in reasons])
 
    # body_lines.append("")
    # body_lines.append(f"Report written to: s3://{ARTIFACT_BUCKET}/{key}")

    # sns.publish(
    #     TopicArn=DONE_TOPIC_ARN,
    #     Subject=subject,
    #     Message="\n".join(body_lines),
    # )
    
    # subject = f"Launch Window Check Complete — {mission}"
    # body_lines = [
    #    f"Decision: {decision}",
    #    f"Mission: {mission}",
    #    f"Site: {launch_site}",
    #    f"Vehicle: {vehicle}",
    #    f"Wind: {constraints['wind_speed_kts']} kts (max {MAX_WIND_KTS})",
    #    f"Cloud ceiling: {constraints['cloud_ceiling_ft']} ft (min {MIN_CLOUD_CEILING_FT})",
    #    f"Lightning risk: {constraints['lightning_risk']} (allowed {LIGHTNING_ALLOWED})",
    #    f"Range status: {constraints['range_status']} (allowed {RANGE_ALLOWED})",
    # ]
    
    # if reasons:
    #    body_lines.append("")
    #    body_lines.append("NO-GO reasons:")
    #    body_lines.extend([f"- {r}" for r in reasons])

    # body_lines.append("")
    # body_lines.append(f"Report written to: s3://{ARTIFACT_BUCKET}/{key}")

    # sns.publish(
    #     TopicArn=DONE_TOPIC_ARN,
    #     Subject=subject,
    #     Message="\n".join(body_lines),
    # )
    
    print(json.dumps({"status": "ok", "decision": decision}))

    return {
        "result": 200
    }


