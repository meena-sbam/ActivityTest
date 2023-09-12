import re
from pymongo import MongoClient
from bs4 import BeautifulSoup


#method to validate if email format is correct
#returns true if validation passes else returns false
def email_validation(email_id):
    pattern= r'\b[A-Za-z0-9._%+-]+@+[A-Za-z0-9]+.+[A-Za-z]{2,}\b'
    return bool(re.fullmatch(pattern,email_id))


#Read the xml file passed and returns the list of testid and status
def xmlparsing(file):
    try:
        with open(file,'r') as f:
            data= f.read()
        bs_data=BeautifulSoup(data,"xml")
        list_id_status=[]
        for i in range(1,10):
            test_id = "s1-t"+str(i)
            test_id_status=bs_data.find("test",{"id":test_id}).status["status"]
            list_id_status.append([test_id,test_id_status])

        return list_id_status

    except Exception as e:
        print(e)


#Get the result status from output.xml file and log it in mongodb
def logresults_mongodb(username,password,dbname, collectionname, filetoparse):

    try:
        connection=f"mongodb+srv://{username}:{password}@cluster0.qucbuxl.mongodb.net/"
        client=MongoClient(connection)
        db=client[dbname]
        coll=db[collectionname]
        # Getting the list of testid and status from xml file
        list_testResults=xmlparsing(filetoparse)

        #looping throught the list from xml file
        for l in list_testResults:
            test=coll.find_one({"testid":l[0]})
            db_value={"testid":l[0],"status":l[1]}
            if test==None:
                #if no records are found with the test id in db then insert one
                coll.insert_one(db_value)
            else:
                #if record with the test id already exists then update the test status
                coll.update_one({"testid":l[0]},{"$set":db_value})

        result=[record for record in coll.find()]
        #returns the collection records
        return result

    except Exception as e:
        print(e)

    finally:
        client.close()






