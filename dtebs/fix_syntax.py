import re

# Fix all files by removing specific erroneous closing parentheses

files_to_fix = [
    (r"c:\xampp\htdocs\DTEBS\dtebs\lib\features\auth\screens\signup_screen.dart", 229),
    (r"c:\xampp\htdocs\DTEBS\dtebs\lib\features\customer\screens\customer_home_screen.dart", 334),
    (r"c:\xampp\htdocs\DTEBS\dtebs\lib\features\booking\screens\booking_screen.dart", 292),
    (r"c:\xampp\htdocs\DTEBS\dtebs\lib\features\customer\screens\restaurant_detail_page.dart", 246),
    (r"c:\xampp\htdocs\DTEBS\dtebs\lib\features\restaurant\screens\restaurant_details_screen.dart", 777),
]

for filepath, error_line in files_to_fix:
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        # The error is usually an extra "),\n" line - remove it
        if error_line - 1 < len(lines):
            # Check if this line is just "),\r\n" or similar
            line_content = lines[error_line - 1].strip()
            if line_content == "),":
                # Remove this line
                lines.pop(error_line - 1)
                print(f"Fixed {filepath} by removing line {error_line}")
                
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.writelines(lines)
            else:
                print(f"Line {error_line} in {filepath} doesn't match expected pattern: '{line_content}'")
    except Exception as e:
        print(f"Error processing {filepath}: {e}")

print("Done!")
