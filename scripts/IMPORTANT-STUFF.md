## Essential JSON Tools for Shell Scripts

### 1. **Core Tools**

- **`jq`**:
  The gold standard for JSON parsing.

  ```bash
  # Extract values
  echo '{"name":"Alice"}' | jq '.name'  # "Alice"

  # Advanced filtering
  curl api.example.com | jq '.[] | select(.score > 90)'
  ```

---

### 2. **Modern Alternatives**

- **`fx`**: Interactive JSON browser with JS syntax

  ```bash
  curl api.example.com | fx 'data => data.filter(x => x.score > 90)'
  ```

- **`jello`**: Python-powered JSON processor

  ```bash
  echo '{"items": [1,2,3]}' | jello 'len(data["items"])'
  ```

- **`sq`**: Database/JSON Swiss Army knife

  ```bash
  sq @data.json '.users | .name, .email'
  ```

---

### 3. **Specialized Tools**

- **`yq`**: YAML equivalent of jq (handles JSON too)

  ```bash
  yq eval '.config.services' docker-compose.yml
  ```

- **`jc`**: Convert command output to JSON

  ```bash
  df | jc --df | jq '.[].used'
  ```

- **`jo`**: Create JSON objects

  ```bash
  jo -p name=Alice age=30 status="active"
  ```

---

### 4. **Built-in Bash Techniques**

**When dependencies aren't possible**:

```bash
# Extract simple values
json='{"title":"Nvim", "floating":false}'
title=$(grep -Po '"title":\s*"\K[^"]+' <<< "$json")

# Toggle boolean values
modified_json=$(sed 's/"floating":false/"floating":true/' <<< "$json")
```

---

### 5. **Interactive Tools**

| Tool | Best For | Install |
|------|----------|---------|
| `fx` | Live JSON exploration | `npm install -g fx` |
| `ramda-cli` | Functional programming | `npm install -g ramda-cli` |
| `jid` | Interactive JSON filtering | `brew install jid` |

---

### 6. **Alternative Approaches**

- **Python's `json.tool`** (Pre-installed):

  ```bash
  echo '{"data":123}' | python3 -m json.tool
  ```

- **Perl/awk**: For complex parsing without dependencies  

  ```bash
  awk -F'"' '/"title":/ {print $4}' data.json
  ```

---

## When to Use What

- **For scripts**: `jq` (if available) or `jello` (for Python shops)
- **Interactive use**: `fx` or `ramda-cli`
- **Minimal dependencies**: Built-in `grep/sed/awk` patterns
- **YAML/JSON crossover**: `yq`

*Pro Tip*: Combine with `fzf` for interactive filtering:  

```bash
curl api.example.com | fx | fzf
```
