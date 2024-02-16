use std::{collections::HashMap, sync::Arc};

pub(super) type PickerQuery = HashMap<&'static str, Arc<str>>;

pub(super) fn parse(
    column_names: &[&'static str],
    primary_column: usize,
    input: &str,
) -> PickerQuery {
    let mut fields: HashMap<&'static str, String> = HashMap::new();
    let primary_field = column_names[primary_column];
    let mut escaped = false;
    let mut quoted = false;
    let mut in_field = false;
    let mut field = None;
    let mut text = String::new();

    macro_rules! finish_field {
        () => {
            let key = field.take().unwrap_or(primary_field);

            if let Some(pattern) = fields.get_mut(key) {
                pattern.push(' ');
                pattern.push_str(&text);
                text.clear();
            } else {
                fields.insert(key, std::mem::take(&mut text));
            }
        };
    }

    for ch in input.chars() {
        match ch {
            // Backslash escaping
            '\\' => escaped = !escaped,
            _ if escaped => {
                // Allow escaping '%' and '"'
                if !matches!(ch, '%' | '"') {
                    text.push('\\');
                }
                text.push(ch);
                escaped = false;
            }
            // Double quoting
            '"' => quoted = !quoted,
            '%' | ':' | ' ' if quoted => text.push(ch),
            // Space either completes the current word if no field is specified
            // or field if one is specified.
            '%' | ' ' if !text.is_empty() => {
                finish_field!();
                in_field = ch == '%';
            }
            '%' => in_field = true,
            ':' if in_field => {
                // Go over all columns and their indices, find all that starts with field key,
                // select a column that fits key the most.
                field = column_names
                    .iter()
                    .filter(|col| col.starts_with(&text))
                    // select "fittest" column
                    .min_by_key(|col| col.len())
                    .copied();
                text.clear();
                in_field = false;
            }
            _ => text.push(ch),
        }
    }

    if !in_field && !text.is_empty() {
        finish_field!();
    }

    fields
        .into_iter()
        .map(|(field, query)| (field, query.as_str().into()))
        .collect()
}

#[cfg(test)]
mod test {
    use helix_core::hashmap;

    use super::*;

    #[test]
    fn parse_query_test() {
        let columns = &["primary", "field1", "field2", "another", "anode"];
        let primary_column = 0;

        // Basic field splitting
        assert_eq!(
            parse(columns, primary_column, "hello world"),
            hashmap!(
                "primary" => "hello world".into(),
            )
        );
        assert_eq!(
            parse(columns, primary_column, "hello %field1:world %field2:!"),
            hashmap!(
                "primary" => "hello".into(),
                "field1" => "world".into(),
                "field2" => "!".into(),
            )
        );
        assert_eq!(
            parse(columns, primary_column, "%field1:abc %field2:def xyz"),
            hashmap!(
                "primary" => "xyz".into(),
                "field1" => "abc".into(),
                "field2" => "def".into(),
            )
        );

        // Trailing space is trimmed
        assert_eq!(
            parse(columns, primary_column, "hello "),
            hashmap!(
                "primary" => "hello".into(),
            )
        );

        // Trailing fields are trimmed.
        assert_eq!(
            parse(columns, primary_column, "hello %foo"),
            hashmap!(
                "primary" => "hello".into(),
            )
        );

        // Quoting
        assert_eq!(
            parse(columns, primary_column, r#"hello %field1:"a b c""#),
            hashmap!(
                "primary" => "hello".into(),
                "field1" => "a b c".into(),
            )
        );

        // Escaping
        assert_eq!(
            parse(columns, primary_column, r#"hello\ world"#),
            hashmap!(
                "primary" => r#"hello\ world"#.into(),
            )
        );
        assert_eq!(
            parse(columns, primary_column, r#"hello \%field1:world"#),
            hashmap!(
                "primary" => "hello %field1:world".into(),
            )
        );
        assert_eq!(
            parse(columns, primary_column, r#"hello %field1:"a\"b""#),
            hashmap!(
                "primary" => "hello".into(),
                "field1" => r#"a"b"#.into(),
            )
        );
        assert_eq!(
            parse(columns, primary_column, r#"%field1:hello\ world"#),
            hashmap!(
                "field1" => r#"hello\ world"#.into(),
            )
        );
        assert_eq!(
            parse(columns, primary_column, r#"%field1:"hello\ world""#),
            hashmap!(
                "field1" => r#"hello\ world"#.into(),
            )
        );
        assert_eq!(
            parse(columns, primary_column, r#"\bfoo\b"#),
            hashmap!(
                "primary" => r#"\bfoo\b"#.into(),
            )
        );

        // Prefix
        assert_eq!(
            parse(columns, primary_column, "hello %anot:abc"),
            hashmap!(
                "primary" => "hello".into(),
                "another" => "abc".into(),
            )
        );
        assert_eq!(
            parse(columns, primary_column, "hello %ano:abc"),
            hashmap!(
                "primary" => "hello".into(),
                "anode" => "abc".into()
            )
        );
        assert_eq!(
            parse(columns, primary_column, "hello %field1:xyz %fie:abc"),
            hashmap!(
                "primary" => "hello".into(),
                "field1" => "xyz abc".into()
            )
        );
        assert_eq!(
            parse(columns, primary_column, "hello %fie:abc"),
            hashmap!(
                "primary" => "hello".into(),
                "field1" => "abc".into()
            )
        );
    }
}
