"""
Fix corrupted Dart files by removing duplicate content appended by PowerShell command.
The command appended all file contents together, so we need to extract only the first valid class.
"""

import os
import re

def fix_dart_file(filepath):
    """Extract only the first valid Dart class/content from a corrupted file."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Find all import statements
        import_pattern = r'^import\s+[\'"].*?[\'"];?\s*$'
        imports = []
        lines = content.split('\n')
        
        # Collect imports from the beginning
        i = 0
        while i < len(lines):
            line = lines[i].strip()
            if line.startswith('import '):
                imports.append(lines[i])
                i += 1
            elif line == '' or line.startswith('//'):
                i += 1
            else:
                break
        
        # Find where the first class/widget starts
        class_start = i
        
        # Find where the first complete class ends (matching braces)
        brace_count = 0
        class_end = class_start
        in_class = False
        
        for j in range(class_start, len(lines)):
            line = lines[j]
            if 'class ' in line and not in_class:
                in_class = True
            
            if in_class:
                brace_count += line.count('{')
                brace_count -= line.count('}')
                
                if brace_count == 0 and in_class:
                    class_end = j + 1
                    break
        
        # Reconstruct the file with only first occurrence
        clean_lines = imports + [''] + lines[class_start:class_end]
        clean_content = '\n'.join(clean_lines)
        
        # Write back
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(clean_content)
        
        print(f"✓ Fixed: {filepath} ({len(lines)} -> {len(clean_lines)} lines)")
        return True
        
    except Exception as e:
        print(f"✗ Error fixing {filepath}: {e}")
        return False

def main():
    lib_dir = 'lib'
    dart_files = []
    
    # Find all Dart files
    for root, dirs, files in os.walk(lib_dir):
        for file in files:
            if file.endswith('.dart'):
                dart_files.append(os.path.join(root, file))
    
    print(f"Found {len(dart_files)} Dart files to fix...\n")
    
    fixed = 0
    for filepath in dart_files:
        if fix_dart_file(filepath):
            fixed += 1
    
    print(f"\n✓ Fixed {fixed}/{len(dart_files)} files")

if __name__ == '__main__':
    main()
