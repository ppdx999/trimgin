use std::io::{self, BufReader, BufRead};

fn is_blank(c: char) -> bool {
    c == ' ' || c == '\t' || c == '\n'
}

fn main() {
    let first_arg = std::env::args().nth(1);

    if let Some(arg) = &first_arg {
        if arg == "-h" || arg == "--help" {
            let help = r#"Usage: trimgin [FILE]

Remove leading and trailing whitespace from text.
If FILE is not provided, read from stdin.

For example:

```text.txt


Hi there!
We have two blank lines above and below this text.
And this space will be removed by 'trimgin'.


```

```terminal
$ trimgin text.txt
Hi there!
We have two blank lines above and below this text.
And this space will be removed by 'trimgin'.
```"#;
            println!("{}", help);

            std::process::exit(0);
        }
    }

    let reader: Box<dyn BufRead> = match first_arg {
        Some(file) => {
            if file == "-" {
                Box::new(BufReader::new(io::stdin()))
            } else {
                Box::new(BufReader::new(std::fs::File::open(file).unwrap()))
            }
        },
        None => Box::new(BufReader::new(io::stdin())),
    };

    let mut buf = String::new();
    let mut leading_blank = true;

    // Read line by line to avoid reading the whole file into memory
    for line in reader.lines() {
        for c in line.unwrap().chars() {
            if leading_blank && is_blank(c) {
                continue;
            }
            leading_blank = false;

            buf.push(c);

            if !is_blank(c) {
                print!("{}", buf);
                buf.clear();
            }
        }
    }
}
