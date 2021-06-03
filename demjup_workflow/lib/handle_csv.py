# libraries
import csv

# get the data from the csv_file, assuming first column is integer id
def read_csv_data(input_file, id_field='id'):
    csv_data = {}
    fieldnames = []
    try:
        with open(input_file, encoding="utf8") as csvfile:
            reader = csv.DictReader(csvfile)
            for row in reader:  
                if fieldnames == []:
                    fieldnames = list(row.keys())
                csv_data[int(row[id_field])]=row
    except FileNotFoundError:
            print("The specified file does not exist")
    return csv_data, fieldnames

# writes data to the given file name
def write_csv_data(values, filename):
    fieldnames = []
    for item in values.keys():
        for key in values[item].keys():
            if not key in fieldnames:
                fieldnames.append(key)
    #write back to a new csv file
    with open(filename, 'w', newline='', encoding="utf-8") as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for key in values.keys():
            writer.writerow(values[key])