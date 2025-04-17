# To add more custom snippets

1. Add the <language>.json file to the snippets/ config
2. Create a snippet like this:

```json
{
    "<snippet name>": {
        "prefix": "<something>",
        "body": ["<the actual snippet>"],
        "description": "<well you know what goes here>"
    }
}
```

## To create placeholder values

```json
{
    "For Loop": {
        "prefix": "forloop",
        "body": [
        "for ${1:i} = ${2:1}, ${3:10} do",
        "\t${0:-- code}",
        "end"
        ]
    }
}
```
