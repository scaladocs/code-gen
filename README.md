Scala Docs Code Gen Utils
-------------------------

This repository contains utility scripts used to aid in codegeneration for
[scaladocs/scaladocs][scaladocs] repository.

## Scripts:

### Generate Examples Scala Package From TSV

- **Input**: TSV(tab-separated-file) with data describing the examples scala 
  pacakge that should be generated.
- **Output**: Scala package file that can be dropped into the ScalaDocs Repository.
  `/out/docs/src/com/scaladocs/exampels/${packageObjectName}/package.scala`
- **Requirements**: [GAWK][GAWK]
- **Running**: `awk -f spreadsheet/code_gen.awk spreadsheet/example.tsv`

```bash
awk -f spreadsheet/code_gen.awk "${PATH_TO_TSV_FILE}"
```

[GAWK]: https://www.gnu.org/software/gawk/
[scaladocs]: https://github.com/scaladocs/scaladocs
