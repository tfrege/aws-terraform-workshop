
## String Functions

| Function | Description | Example |
|----------|-------------|---------|
| `chomp(string)` | Removes newline characters from end of string | `chomp("hello\n")` → `"hello"` |
| `format(spec, values...)` | Formats string using printf-style syntax | `format("Hello, %s!", "World")` → `"Hello, World!"` |
| `formatlist(spec, lists...)` | Formats each element of a list | `formatlist("Hello, %s!", ["A", "B"])` → `["Hello, A!", "Hello, B!"]` |
| `indent(num, string)` | Adds spaces to beginning of each line | `indent(4, "hello")` → `"    hello"` |
| `join(separator, list)` | Joins list elements with separator | `join(", ", ["a", "b"])` → `"a, b"` |
| `lower(string)` | Converts string to lowercase | `lower("HELLO")` → `"hello"` |
| `regex(pattern, string)` | Matches regex pattern in string | `regex("[a-z]+", "abc123")` → `"abc"` |
| `regexall(pattern, string)` | Returns all regex matches | `regexall("[0-9]+", "a1b2")` → `["1", "2"]` |
| `replace(string, search, replace)` | Replaces occurrences in string | `replace("hello", "l", "L")` → `"heLLo"` |
| `split(separator, string)` | Splits string into list | `split(",", "a,b,c")` → `["a", "b", "c"]` |
| `strrev(string)` | Reverses string | `strrev("hello")` → `"olleh"` |
| `substr(string, offset, length)` | Extracts substring | `substr("hello", 1, 3)` → `"ell"` |
| `title(string)` | Converts to title case | `title("hello world")` → `"Hello World"` |
| `trim(string, chars)` | Removes characters from start/end | `trim("?hello?", "?")` → `"hello"` |
| `trimprefix(string, prefix)` | Removes prefix from string | `trimprefix("helloworld", "hello")` → `"world"` |
| `trimsuffix(string, suffix)` | Removes suffix from string | `trimsuffix("helloworld", "world")` → `"hello"` |
| `trimspace(string)` | Removes whitespace from start/end | `trimspace("  hello  ")` → `"hello"` |
| `upper(string)` | Converts string to uppercase | `upper("hello")` → `"HELLO"` |

## Numeric Functions

| Function | Description | Example |
|----------|-------------|---------|
| `abs(number)` | Returns absolute value | `abs(-5)` → `5` |
| `ceil(number)` | Rounds up to nearest integer | `ceil(4.3)` → `5` |
| `floor(number)` | Rounds down to nearest integer | `floor(4.7)` → `4` |
| `log(number, base)` | Calculates logarithm | `log(16, 2)` → `4` |
| `max(numbers...)` | Returns maximum value | `max(5, 12, 9)` → `12` |
| `min(numbers...)` | Returns minimum value | `min(5, 12, 9)` → `5` |
| `parseint(string, base)` | Parses string to integer | `parseint("100", 10)` → `100` |
| `pow(base, exponent)` | Raises number to power | `pow(2, 3)` → `8` |
| `signum(number)` | Returns sign of number (-1, 0, 1) | `signum(-5)` → `-1` |

## Collection Functions

| Function | Description | Example |
|----------|-------------|---------|
| `alltrue(list)` | Returns true if all elements are true | `alltrue([true, true])` → `true` |
| `anytrue(list)` | Returns true if any element is true | `anytrue([false, true])` → `true` |
| `chunklist(list, size)` | Splits list into chunks | `chunklist([1,2,3,4], 2)` → `[[1,2], [3,4]]` |
| `coalesce(values...)` | Returns first non-null value | `coalesce("", "a", "b")` → `"a"` |
| `coalescelist(lists...)` | Returns first non-empty list | `coalescelist([], ["a"])` → `["a"]` |
| `compact(list)` | Removes empty strings from list | `compact(["a", "", "b"])` → `["a", "b"]` |
| `concat(lists...)` | Concatenates lists | `concat([1,2], [3,4])` → `[1,2,3,4]` |
| `contains(list, value)` | Checks if list contains value | `contains([1,2,3], 2)` → `true` |
| `distinct(list)` | Removes duplicates from list | `distinct([1,2,2,3])` → `[1,2,3]` |
| `element(list, index)` | Returns element at index (wraps) | `element([1,2,3], 0)` → `1` |
| `flatten(list)` | Flattens nested lists | `flatten([[1,2], [3,4]])` → `[1,2,3,4]` |
| `index(list, value)` | Returns index of value in list | `index([1,2,3], 2)` → `1` |
| `keys(map)` | Returns list of map keys | `keys({a=1, b=2})` → `["a", "b"]` |
| `length(collection)` | Returns length of collection | `length([1,2,3])` → `3` |
| `list(values...)` | Creates list (deprecated) | `list(1, 2, 3)` → `[1, 2, 3]` |
| `lookup(map, key, default)` | Looks up value in map | `lookup({a=1}, "a", 0)` → `1` |
| `map(key, value, ...)` | Creates map (deprecated) | `map("a", 1)` → `{a = 1}` |
| `matchkeys(values, keys, search)` | Filters values by matching keys | `matchkeys(["a","b"], [1,2], [1])` → `["a"]` |
| `merge(maps...)` | Merges maps | `merge({a=1}, {b=2})` → `{a=1, b=2}` |
| `one(list)` | Returns single element or null | `one([1])` → `1` |
| `range(start, limit, step)` | Generates numeric sequence | `range(1, 4)` → `[1, 2, 3]` |
| `reverse(list)` | Reverses list order | `reverse([1,2,3])` → `[3,2,1]` |
| `setintersection(sets...)` | Returns intersection of sets | `setintersection([1,2], [2,3])` → `[2]` |
| `setproduct(sets...)` | Returns Cartesian product | `setproduct([1,2], ["a"])` → `[[1,"a"], [2,"a"]]` |
| `setsubtract(set1, set2)` | Subtracts set2 from set1 | `setsubtract([1,2,3], [2])` → `[1, 3]` |
| `setunion(sets...)` | Returns union of sets | `setunion([1,2], [2,3])` → `[1,2,3]` |
| `slice(list, start, end)` | Extracts sublist | `slice([1,2,3,4], 1, 3)` → `[2,3]` |
| `sort(list)` | Sorts list alphabetically | `sort(["c", "a", "b"])` → `["a", "b", "c"]` |
| `sum(list)` | Sums numeric list | `sum([1, 2, 3])` → `6` |
| `transpose(map)` | Transposes map of lists | `transpose({a=["1"], b=["1"]})` → `{"1"=["a","b"]}` |
| `values(map)` | Returns list of map values | `values({a=1, b=2})` → `[1, 2]` |
| `zipmap(keys, values)` | Creates map from lists | `zipmap(["a","b"], [1,2])` → `{a=1, b=2}` |

## Encoding Functions

| Function | Description | Example |
|----------|-------------|---------|
| `base64decode(string)` | Decodes base64 string | `base64decode("aGVsbG8=")` → `"hello"` |
| `base64encode(string)` | Encodes string to base64 | `base64encode("hello")` → `"aGVsbG8="` |
| `base64gzip(string)` | Compresses and encodes to base64 | `base64gzip("hello")` → compressed string |
| `csvdecode(string)` | Parses CSV into list of maps | `csvdecode("a,b\n1,2")` → `[{a="1",b="2"}]` |
| `jsondecode(string)` | Parses JSON string | `jsondecode("{\"a\":1}")` → `{a = 1}` |
| `jsonencode(value)` | Encodes value to JSON | `jsonencode({a=1})` → `"{\"a\":1}"` |
| `textdecodebase64(string, encoding)` | Decodes base64 with encoding | `textdecodebase64("aGVsbG8=", "UTF-8")` → `"hello"` |
| `textencodebase64(string, encoding)` | Encodes to base64 with encoding | `textencodebase64("hello", "UTF-8")` → `"aGVsbG8="` |
| `urlencode(string)` | URL encodes string | `urlencode("hello world")` → `"hello+world"` |
| `yamldecode(string)` | Parses YAML string | `yamldecode("a: 1")` → `{a = 1}` |
| `yamlencode(value)` | Encodes value to YAML | `yamlencode({a=1})` → `"a: 1\n"` |

## Filesystem Functions

| Function | Description | Example |
|----------|-------------|---------|
| `abspath(path)` | Returns absolute path | `abspath("./file.txt")` → `"/full/path/file.txt"` |
| `basename(path)` | Returns filename from path | `basename("/path/to/file.txt")` → `"file.txt"` |
| `dirname(path)` | Returns directory from path | `dirname("/path/to/file.txt")` → `"/path/to"` |
| `file(path)` | Reads file contents | `file("config.txt")` → file contents |
| `filebase64(path)` | Reads file as base64 | `filebase64("image.png")` → base64 string |
| `filebase64sha256(path)` | Returns base64 SHA256 hash | `filebase64sha256("file.txt")` → hash |
| `filebase64sha512(path)` | Returns base64 SHA512 hash | `filebase64sha512("file.txt")` → hash |
| `fileexists(path)` | Checks if file exists | `fileexists("file.txt")` → `true/false` |
| `filemd5(path)` | Returns MD5 hash of file | `filemd5("file.txt")` → hash |
| `fileset(path, pattern)` | Returns set of matching files | `fileset(".", "*.tf")` → `["main.tf"]` |
| `filesha1(path)` | Returns SHA1 hash of file | `filesha1("file.txt")` → hash |
| `filesha256(path)` | Returns SHA256 hash of file | `filesha256("file.txt")` → hash |
| `filesha512(path)` | Returns SHA512 hash of file | `filesha512("file.txt")` → hash |
| `pathexpand(path)` | Expands ~ in path | `pathexpand("~/file.txt")` → `"/home/user/file.txt"` |
| `templatefile(path, vars)` | Renders template file | `templatefile("tpl.txt", {name="x"})` → rendered |

## Date and Time Functions

| Function | Description | Example |
|----------|-------------|---------|
| `formatdate(format, timestamp)` | Formats timestamp | `formatdate("YYYY-MM-DD", timestamp())` → `"2024-01-15"` |
| `plantimestamp()` | Returns plan execution timestamp | `plantimestamp()` → `"2024-01-15T10:30:00Z"` |
| `timeadd(timestamp, duration)` | Adds duration to timestamp | `timeadd(timestamp(), "1h")` → future time |
| `timecmp(time1, time2)` | Compares timestamps (-1, 0, 1) | `timecmp("2024-01-01", "2024-01-02")` → `-1` |
| `timestamp()` | Returns current timestamp | `timestamp()` → `"2024-01-15T10:30:00Z"` |

## Hash and Crypto Functions

| Function | Description | Example |
|----------|-------------|---------|
| `base64sha256(string)` | Returns base64 SHA256 hash | `base64sha256("hello")` → hash |
| `base64sha512(string)` | Returns base64 SHA512 hash | `base64sha512("hello")` → hash |
| `bcrypt(string, cost)` | Generates bcrypt hash | `bcrypt("password", 10)` → hash |
| `md5(string)` | Returns MD5 hash | `md5("hello")` → hash |
| `rsadecrypt(ciphertext, key)` | Decrypts with RSA private key | `rsadecrypt(encrypted, key)` → plaintext |
| `sha1(string)` | Returns SHA1 hash | `sha1("hello")` → hash |
| `sha256(string)` | Returns SHA256 hash | `sha256("hello")` → hash |
| `sha512(string)` | Returns SHA512 hash | `sha512("hello")` → hash |
| `uuid()` | Generates UUID | `uuid()` → `"550e8400-e29b-41d4-a716-446655440000"` |
| `uuidv5(namespace, name)` | Generates UUID v5 | `uuidv5("dns", "example.com")` → UUID |

## IP Network Functions

| Function | Description | Example |
|----------|-------------|---------|
| `cidrhost(prefix, hostnum)` | Calculates IP address in CIDR | `cidrhost("10.0.0.0/24", 5)` → `"10.0.0.5"` |
| `cidrnetmask(prefix)` | Returns netmask from CIDR | `cidrnetmask("10.0.0.0/24")` → `"255.255.255.0"` |
| `cidrsubnet(prefix, newbits, netnum)` | Calculates subnet address | `cidrsubnet("10.0.0.0/16", 8, 1)` → `"10.0.1.0/24"` |
| `cidrsubnets(prefix, newbits...)` | Calculates multiple subnets | `cidrsubnets("10.0.0.0/16", 8, 8)` → list of subnets |

## Type Conversion Functions

| Function | Description | Example |
|----------|-------------|---------|
| `can(expression)` | Tests if expression succeeds | `can(regex("^[a-z]+$", "abc"))` → `true` |
| `defaults(object, defaults)` | Applies default values to object | `defaults({a=1}, {b=2})` → `{a=1, b=2}` |
| `nonsensitive(value)` | Removes sensitive marking | `nonsensitive(sensitive("secret"))` → `"secret"` |
| `sensitive(value)` | Marks value as sensitive | `sensitive("secret")` → sensitive value |
| `tobool(value)` | Converts to boolean | `tobool("true")` → `true` |
| `tolist(value)` | Converts to list | `tolist(["a", "b"])` → `["a", "b"]` |
| `tomap(value)` | Converts to map | `tomap({a=1})` → `{a = 1}` |
| `tonumber(value)` | Converts to number | `tonumber("42")` → `42` |
| `toset(value)` | Converts to set | `toset([1, 2, 2])` → `[1, 2]` |
| `tostring(value)` | Converts to string | `tostring(42)` → `"42"` |
| `try(expressions...)` | Returns first successful expression | `try(var.a, "default")` → first valid value |
| `type(value)` | Returns type of value | `type([])` → `"list"` |

## Terraform-Specific Functions

| Function | Description | Example |
|----------|-------------|---------|
| `provider::*::*` | Provider-defined functions | Varies by provider |
