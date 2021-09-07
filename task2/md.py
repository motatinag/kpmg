import requests
import json

metadata_url = 'http://169.254.169.254/latest/'


def expand_jsontree(url, arr):
    result = {}
    for item in arr:  #5. extracting the elements one by one by using for loop
        new_url = url + item # 6. adding item to the url soo this url is runned example like 'http://169.254.169.254/latest/meta-data'
        r = requests.get(new_url) # 7. by using above url getting the entire data
        text = r.text# 8. getting only text from the extracted data from the url
        if item[-1] == "/": # 9. checking the last element of text is / or not
            list_of_values = r.text.splitlines() # 10. if above condition is True spiltting the data based on /n
            result[item[:-1]] = expand_jsontree(new_url, list_of_values) #11. now inserting the items into dictionary
        elif is_valid_json(text): # 11. elif calling the is_valid_json() function
            result[item] = json.loads(text)  # 12. converting the data into json data
        else:
            result[item] = text
    return result


def metadata():
    path = ["meta-data", "a", "b", "c"] #3. path is considered as an array
    result = expand_jsontree(metadata_url, path) # 4. calling expand_jsontree function by passing url and path as param
    return result


def metadata_json():
    md = metadata()#2. calling metadata() function
    metadata_json = json.dumps(md, indent=4, sort_keys=True)
    return metadata_json


def is_valid_json(value):
    try:
        json.loads(value)
    except ValueError:
        return False
    return True


if __name__ == '__main__':
    print(metadata_json()) #1. calling metadata_json function
