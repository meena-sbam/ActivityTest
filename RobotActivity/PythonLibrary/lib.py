import re
from pymongo import MongoClient
from bs4 import BeautifulSoup
import time


#method to validate if email format is correct
#returns true if validation passes else returns false
def email_validation(email_id):
    pattern= r'\b[A-Za-z0-9._%+-]+@+[A-Za-z0-9]+.+[A-Za-z]{2,}\b'
    return bool(re.fullmatch(pattern,email_id))

def xmlparsing(file, test_name):
    with open('output.xml','r') as f:
        data= f.read()
    bs_data=BeautifulSoup(data,"xml")
    #test_status=bs_data.find("test",{"name":test_name}).status["status"]
    list_id_status=[]
    for i in range(1,10):
        test_id = "s1-t"+str(i)
        test_id_status=bs_data.find("test",{"id":test_id}).status["status"]
        list_id_status.append([test_id,test_id_status])

    return list_id_status


def logresults_mongodb(username,password):
    connection=f"mongodb+srv://{username}:{password}@cluster0.qucbuxl.mongodb.net/"
    client=MongoClient(connection)
    db=client["Testdb"]
    coll=db["TestStatus"]
    list_testResults=xmlparsing('output.xml',"test")
    for l in list_testResults:
        test=coll.find_one({"testid":l[0]})
        db_value={"testid":l[0],"status":l[1]}
        if test==None:
            coll.insert_one(db_value)
        else:
            coll.update_one({"testid":l[0]},{"$set":db_value})

    result=[record for record in coll.find()]

    return result






