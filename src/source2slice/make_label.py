## coding:utf-8
import os
import pickle


f = open("dict_cwe2father.pkl", 'rb')
dict_cwe2father = pickle.load(f)
f.close()

#print dict_cwe2father['CWE-787']

f = open("label_vec_type.pkl", 'rb')
label_vec_type = pickle.load(f)
f.close()

f = open("dict_testcase2code.pkl",'rb')
dict_testcase2code = pickle.load(f)
f.close()


def get_label_veclist(list_cwe):
    list_label = [0] * len(label_vec_type)
    for cweid in list_cwe:
        index = label_vec_type.index(cweid)
        list_label[index] = 1

    return list_label


def get_label_cwe(cweid, label_cwe):
    if cweid in label_vec_type:
        label_cwe.append(cweid)
        return label_cwe

    else:
        if cweid == 'CWE-1000':
            label_cwe = label_vec_type
        else:
            fathercweid = dict_cwe2father[cweid]

            for _id in fathercweid:
                label_cwe = get_label_cwe(_id, label_cwe)

    return label_cwe


def make_label(path, dict_vuln2testcase, _type):
    f = open(path, 'r')
    context = f.read().split('------------------------------')[:-1]
    f.close()

    context[0] = '\n' + context[0]

    list_all_label = []
    list_all_vulline = []
    for _slice in context:
        vulline = []
        index_line = _slice.split('\n')[1] 
        list_codes = _slice.split('\n')[2:-1] 
        case_name = index_line.split(' ')[1]
        key_name = '/'.join(index_line.split(' ')[1].split('/')[-2:])
        print index_line

        if key_name in dict_vuln2testcase.keys():
            list_codeline = [code.split(' ')[-1] for code in list_codes]
            dict = dict_vuln2testcase[key_name]

            _dict_cwe2line_target = {}
            _dict_cwe2line = {}
	    for _dict in dict: 
                for key in _dict.keys():
                    if _dict[key] not in _dict_cwe2line_target.keys():
                        _dict_cwe2line_target[_dict[key]] = [key] 
                    else:
                        _dict_cwe2line_target[_dict[key]].append(key)

                
                for line in list_codeline:
                    line = line.strip()
                    if line in _dict.keys():
                        if not ' '.join((list_codes[list_codeline.index(line)].strip()).split(' ')[:-1]) == dict_testcase2code[key_name+"/"+line].strip():
                            continue
                        cweid = _dict[line]
                        vulline.append(list_codeline.index(line))

                        if cweid not in _dict_cwe2line.keys():
                            _dict_cwe2line[cweid] = [line]
                        else:
                            _dict_cwe2line[cweid].append(line)

            if _type:
                list_vuln_cwe = []
                for key in _dict_cwe2line.keys():
                    if key == 'Any...':
                        continue
                    if len(_dict_cwe2line[key]) == len(_dict_cwe2line_target[key]):
                        label_cwe = []
                        label_cwe = get_label_cwe(key, label_cwe)
                        list_vuln_cwe += label_cwe

            else:
                list_vuln_cwe = []
                for key in _dict_cwe2line.keys():
                    if key == 'Any...':
                        continue
                    label_cwe = []
                    label_cwe = get_label_cwe(key, label_cwe)
                    list_vuln_cwe += label_cwe

            if list_vuln_cwe == []:
                list_label = [0] * len(label_vec_type)
            else:
                list_vuln_cwe = list(set(list_vuln_cwe))
                list_label = get_label_veclist(list_vuln_cwe)
            
        else:
            list_label = [0] * len(label_vec_type)

        list_all_label.append(list_label)
        list_all_vulline.append(vulline)

    return list_all_label, list_all_vulline


def main():
    f = open("dict_flawline2filepath.pkl", 'rb')
    dict_vuln2testcase = pickle.load(f)
    f.close()
    _type = False
    time = '4'
   # lang = 'C/test_data/' + time
    lang = ''
    
    path = os.path.join(lang, 'api_slices.txt')
    list_all_apilabel, list_all_vulline = make_label(path, dict_vuln2testcase, _type)
    dec_path = os.path.join(lang, 'api_slices_label.pkl')
    f = open(dec_path, 'wb')
    pickle.dump(list_all_apilabel, f, True)
    f.close()
    dec_path = os.path.join(lang, 'api_slices_vulline.pkl')
    f = open(dec_path, 'wb')
    pickle.dump(list_all_vulline, f)
    f.close()
    
    path = os.path.join(lang, 'arraysuse_slices.txt')
    list_all_arraylabel = make_label(path, dict_vuln2testcase, _type)
    dec_path = os.path.join(lang, 'array_slice_label.pkl')
    f = open(dec_path, 'wb')
    pickle.dump(list_all_arraylabel, f, True)
    f.close()
    
    path = os.path.join(lang, 'pointersuse_slices.txt')
    list_all_pointerlabel = make_label(path, dict_vuln2testcase, _type)
    dec_path = os.path.join(lang, 'pointer_slice_label.pkl')
    f = open(dec_path, 'wb')
    pickle.dump(list_all_pointerlabel, f, True)
    f.close()
 
    path = os.path.join(lang, 'integeroverflow_slices.txt')
    list_all_exprlabel = make_label(path, dict_vuln2testcase, _type)
    dec_path = os.path.join(lang, 'expr_slice_label.pkl')
    f = open(dec_path, 'wb')
    pickle.dump(list_all_exprlabel, f, True)
    f.close()
    

if __name__ == '__main__':
    main()
