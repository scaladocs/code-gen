###############################################################################
# Spreadsheet Code Generation Helper for Scala Docs
#
# Input: TSV(tab-separated-file) with data describing the examples scala 
#        pacakge that should be generated.
# Output: Scala package file that can be dropped into the ScalaDocs Repository.
#     `/out/docs/src/com/scaladocs/exampels/${packageObjectName}/package.scala`
#
# Running:
#   awk -f spreasheet/code_gen input.tsv
#
###############################################################################
function concatLines(a, b, c) {
  if (!c) {
    return a "\n" b;
  }

  return a "\n" b "\n" c;
}

function quote(value) {
  return "\"" value "\""
}

function quoteBlock(value) {
  return "\"\"\"" value "\"\"\".stripMargin.trim"
}

function createTag(label, location) {
  if (!location) {
    return "Tag(" quote(label) ")"
  }
  return "Tag(" quote(label) "," quote(location) ")"
}

function createTags(_tags, _tag, _result) {
  split($example_tags, _tags, ";")
  _result = "";
  for (i = 1; i <= length(_tags); i++) {
    split(_tags[i], _tag, "|")
    _result = _result createTag(_tag[1], _tag[2])
    if (i != length(_tags)) {
      _result = _result ","
    }
  }
  return _result;
}

function createLink(label, location) {
  return "Link(" quote(label) "," quote(location) ")"
}

function createLinks(_links, _link, _result) {
  split($page_links, _links, ";")
  _result = "";
  for (i = 1; i <= length(_links); i++) {
    split(_links[i], _link, "|")
    _result = _result createLink(_link[1], _link[2])
    if (i != length(_links)) {
      _result = _result ","
    }
  }
  return _result;
}

function newExample(_body) {
  _body = "title = " quote($example_title) ","
  _body = concatLines(_body, "description = " quote($example_description) ".some,")
  _body = concatLines(_body, "tags = List(" createTags() "),")
  _body = concatLines(_body, "snippet = Code(" quoteBlock("") ")")

  return concatLines("CodeExample(", _body,")")
}

function newPage(_body) {
  _body = ""
  _body = concatLines(_body, "def canonicalPath = " quote($page_canonical_path))
  _body = concatLines(_body, "def title = " quote($page_title))
  _body = concatLines(_body, "def signature = FQSignature(" quote($page_signature) ")")
  _body = concatLines(_body, "def description: Option[String] = " quoteBlock($page_description) ".some")
  _body = concatLines(_body, "def tags: List[Tag] = List()")
  _body = concatLines(_body, "def links: List[Link] =  List(" createLinks() ")")
  _body = concatLines(_body, "def children: Pages = Nil")
  _body = concatLines(_body, "def examples: CodeExamples = List($EXAMPLES)")
  return concatLines("new Page {", _body ,"}")
}

BEGIN {
  FS="\t"
  package_object_name=1
  page_canonical_path=2	
  page_title=3	
  page_signature=4	
  page_description=5	
  page_tags=6	
  page_links=7	
  example_title=8	
  example_description=9	
  example_tags=10
  example_snippet=11

  # Accumulators:
  page_count=0
  output_prefix = "out/docs/src/com/scaladocs/examples/" 
}

NR == 1 { next }

# When Row is not Empty
$1 != "" {
  page_count += 1
  current_package_name=$package_object_name
  current_page=$page_canonical_path
  example_count[current_page] = 1
  pages[current_page] = newPage()
  examples[current_page, example_count[current_page]] = newExample()
}

{
  example_count[current_page] += 1
  examples[current_page, example_count[current_page]] = newExample()
} 

END {
  _page_contents = ""
  for (page_path in pages) {
    _page_contents = _page_contents "package com.scaladocs.examples\n\n"
    _page_contents = _page_contents "import cats._\n"
    _page_contents = _page_contents "import cats.implicits._\n\n"
    _page_contents = _page_contents "package object " current_package_name " {\n"
    _page_contents = _page_contents "def getPage: Page = " pages[page_path] "\n"
    _page_contents = _page_contents "\n}\n"

    _page_examples = ""
    for (i = 1; i <= example_count[page_path]; i++) {
      _page_examples = concatLines(_page_examples, examples[current_page, i])
      if (i != example_count[page_path]) {
        _page_examples = _page_examples ",\n"
      }
    }

    gsub(/\$EXAMPLES/, _page_examples, _page_contents)

    print "mkdir -p " output_prefix current_package_name | "sh"
    close("sh")

    _package_file = output_prefix current_package_name "/package.scala"
    print _page_contents > _package_file
    close(_package_file)
  }
}
