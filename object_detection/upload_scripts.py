
for bucket in ['anchor_generators', 'box_coders', 'builders', 'core', 'data_decoders', 'matchers', 'meta_architectures', 'protos', 'utils']:
    print('Uploading files for bucket: %s' % (bucket))
    scripts = os.listdir(bucket)
    for script in scripts:
        with open(bucket+'/'+script, 'rb') as f:
            data = f.read()
            res = object_storage.put_object(namespace, bucket, script, data)

# sample_configs
print('Uploading files for bucket: sample_configs')
scripts = os.listdir('samples/configs')
for script in scripts:
    with open('samples/configs/'+script, 'rb') as f:
        data = f.read()
        res = object_storage.put_object(namespace, 'sample_configs', script, data)

# sample_configs
print('Uploading files for bucket: old_inference_graphs')
scripts = os.listdir('saved_graphs')
for script in scripts:
    with open('saved_graphs/'+script, 'rb') as f:
        data = f.read()
        res = object_storage.put_object(namespace, 'old_inference_graphs', script, data)

# sample_configs
print('Uploading files for bucket: slim')
scripts = os.listdir('slim')
for script in scripts:
    if os.path.isfile('slim/'+script):
        with open('slim/'+script, 'rb') as f:
            data = f.read()
            res = object_storage.put_object(namespace, 'slim', script, data)
    else:
        with ZipFile('slim/'+script+'.zip', 'w') as z:
            z.write('slim/'+script)
        with open('slim/'+script+'.zip', 'rb') as f:
            data = f.read()
            res = object_storage.put_object(namespace, 'slim', script+'.zip', data)