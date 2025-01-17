open Indigobi.Gemini.Text

let url_parsing () =
  let _ =
    assert (
      parse "=> gemini://example.org/"
      = [ Link { url = "gemini://example.org/"; name = None } ])
  and _ =
    assert (
      parse "=> gemini://example.org/ An example link"
      = [
          Link { url = "gemini://example.org/"; name = Some "An example link" };
        ])
  and _ =
    assert (
      parse "=> gemini://example.org/foo\tAnother example link at the same host"
      = [
          Link
            {
              url = "gemini://example.org/foo";
              name = Some "Another example link at the same host";
            };
        ])
  and _ =
    assert (
      parse "=> foo/bar/baz.txt\tA relative link"
      = [ Link { url = "foo/bar/baz.txt"; name = Some "A relative link" } ])
  and _ =
    assert (
      parse "=> \tgopher://example.org:70/1 A gopher link"
      = [
          Link
            { url = "gopher://example.org:70/1"; name = Some "A gopher link" };
        ])
  in
  ()

let text =
  {|
# One
## Two
### Three
#### Four

=>
=> Nice link

>A quote

```py
# Print hello world

print("Hello world")
```
```
code
```
|}

let pass () =
  url_parsing ();
  assert (
    parse text
    = [
        Heading (`H1, "One");
        Heading (`H2, "Two");
        Heading (`H3, "Three");
        Text "#### Four";
        Text "";
        Text "=>";
        Link { url = "Nice"; name = Some "link" };
        Text "";
        Quote "A quote";
        Text "";
        Preformat
          {
            alt = Some "py";
            text = "# Print hello world\n\nprint(\"Hello world\")\n";
          };
        Preformat { alt = None; text = "code\n" };
      ])
