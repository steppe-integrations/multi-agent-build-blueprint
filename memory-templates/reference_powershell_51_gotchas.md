# PowerShell 5.1 gotchas

If your machine runs Windows PowerShell 5.1 (the default on Windows 10/11 without the modern PowerShell 7 install), the parser has constraints that bite repeatedly.

## Common bites

- **`Start-Process -ArgumentList` as a string array does NOT auto-quote spaces.** Pass a single pre-quoted string instead. Example: `'--config "file:{0}"' -f $cfg`.
- **No ternary (`?:`).** Use `if/else` or compact `if (cond) { val1 } else { val2 }`.
- **No null-coalescing (`??`).** Use explicit `if ($null -eq $x) { default } else { $x }`.
- **No `&&` / `||` pipeline chains.** Use `; if ($?) { B }` instead.
- **Inline `if` inside `-f` format strings fails.** Compute the value first into a variable.
- **Default file encoding is UTF-16 LE with BOM.** Pass `-Encoding utf8` when writing files other tools will read.
- **Console mojibake with non-ASCII.** Set `[Console]::OutputEncoding = [System.Text.Encoding]::UTF8` if you emit Unicode.

## Quick fix shapes

```powershell
# DO: pre-quoted single string
$argsLine = '--config "file:{0}"' -f $cfg
Start-Process -FilePath $exe -ArgumentList $argsLine

# DON'T: array with spaces
Start-Process -FilePath $exe -ArgumentList @('--config', "file:$cfg")  # spaces break

# DO: explicit if for default
$endpoint = if ($env:OTEL_ENDPOINT) { $env:OTEL_ENDPOINT } else { 'http://localhost:4317' }

# DON'T: $env:OTEL_ENDPOINT ?? 'http://localhost:4317'  # parser error in 5.1

# DO: chained-on-success
git commit -m "msg"; if ($?) { git push }

# DON'T: git commit -m "msg" && git push  # parser error in 5.1
```

## When to upgrade to PS 7

If you control the machine, just install PowerShell 7. It's a side-by-side install, doesn't replace 5.1, and supports all the modern syntax. The PS 5.1 constraints are only worth fighting on machines where you can't or shouldn't install PS 7.
