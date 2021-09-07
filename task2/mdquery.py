from md import metadata

def gen_dict_extract(key, var):
    if hasattr(var, 'items'):
        for k, v in var.items():
            if k == key:
                yield v
            if isinstance(v, dict):
                for result in gen_dict_extract(key, v):
                    yield result
            elif isinstance(v, list):
                for d in v:
                    for result in gen_dict_extract(key, d):
                        yield result


def find_key(key):
    md = metadata()
    return list(gen_dict_extract(key, md))


if __name__ == '__main__':
    key = input("Enter the key name to get the value\n")
    print(find_key(key))
