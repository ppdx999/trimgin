use std::io::{self, BufRead};

fn is_blank(c: char) -> bool {
    c == ' ' || c == '\t' || c == '\n'
}

fn main() {
    let stdin = io::stdin();
    let mut buf = String::new();
    let mut leading_blank = true;

    for line in stdin.lock().lines() {
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
