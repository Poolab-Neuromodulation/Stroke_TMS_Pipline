import re

# raw_data = ''
delay = 2.3
subject_id = 'ME18'
hemi = 'rh'











if __name__ == '__main__':
    file_path = './config.py'
    file_mode = 'r+'
    target_file = open(file_path, file_mode)

    file_content = target_file.read()

    old = re.findall(r'\'delay\': \S+', file_content)[0]
    new_content = file_content.replace(old, f'\'delay\': {delay},')
    old = re.findall(r'\'subject_id\': \S+', new_content)[0]
    new_content = new_content.replace(old, f'\'subject_id\': \'{subject_id}\',')
    old = re.findall(r'\'hemi\': \S+', new_content)[0]
    new_content = new_content.replace(old, f'\'hemi\': \'{hemi}\',')
    # old = re.findall(r'\'source\': \S+', new_content)[0]
    # new_content = new_content.replace(old, f'\'source\': \'{raw_data}\'')

    target_file.seek(0)
    target_file.write(new_content)
    target_file.truncate()
    target_file.close()