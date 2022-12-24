import json

def merge_and_sort_json(json_file1, json_file2):
  # Load the data from the JSON files
  with open(json_file1, 'r') as f:
    data1 = json.load(f)
  with open(json_file2, 'r') as f:
    data2 = json.load(f)

  # Merge the data
  data1.update(data2)
  data2 = {}
  
  # Write the data to the output file
  with open(json_file1, 'w') as f:
    json.dump(data1, f, indent=2)
  with open(json_file2, 'w') as f:
    json.dump(data2, f, indent=2)
def merge_and_sort_json(json_file, output_file1, output_file2,output_file3,output_file4):
  # Load the data from the JSON files
  with open(json_file, 'r') as f:
    data1 = json.load(f)

  out1 = []
  out2 = []
  out3 = {}
  out4 = {}
  for item in data1:
    if data1[item]["isOrg"]:
      out1.append(int(item))
      out3[item]=data1[item]
    else:
      out2.append(int(item)) 
      out4[item]=data1[item]

  # Write the data to the output file
  with open(output_file1, 'w') as f:
    json.dump(out1, f, indent=2)
  with open(output_file2, 'w') as f:
    json.dump(out2, f, indent=2)
  with open(output_file3, 'w') as f:
    json.dump(out3, f, indent=2)
  with open(output_file4, 'w') as f:
    json.dump(out4, f, indent=2)#
    

# Example usage
merge_and_sort_json('orgdata.json', 'orgdata2.json')
merge_and_sort_json('orgdata.json', 'data/org.json', 'data/player.json','data/orgdata.json', 'data/playerdata.json',)