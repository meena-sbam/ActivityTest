*** Settings ***
Documentation    Suite includes the test cases for Functional and Non Functional requirement of gorest api
Library     RequestsLibrary
Library     JSONLibrary
Library     Collections
Library     OperatingSystem
Library     ./PythonLibrary/lib.py
Resource        ./ResourceFile/resource.robot
Test Setup     Session Creation
Test Teardown      Delete All Sessions

*** Variables ***
${baseurl}=     https://gorest.co.in/
${users_endpoint}=     /public/v2/users
${headers}=     Create Dictionary       Content-Type=application/json
${success_statuscode}=  200
${Post_successstatus}=  201
${notfound_statuscode}=     404
${authenticationerror_statuscode}=      401
${unprocessed_statuscode}=      422

*** Test Cases ***

Verify Response has Pagination
        [Documentation]     Validate the API response has pagination
        [Tags]      Functional
        ${response}=    Get Request         ${users_endpoint}      ${success_statuscode}      ${headers}
        #Verifying pagination with header availability of 'x-pagination-page'
        should contain      ${response.headers}     x-pagination-page
        #Verifying pagination by performing get request with page details in query parameters
        ${response_with_page}=    Get Request         /public/v2/users?page=1&per_page=10        ${success_statuscode}

Verify Response has Valid Json Data
        [Documentation]         Validate the response has valid Json data
        [Tags]      Functional
        ${response}=    Get Request         ${users_endpoint}        ${success_statuscode}       ${headers}
        #verify header content type is json
        should contain      ${response.headers["Content-Type"]}          application/json

        #Using python commands to change json to dictionary and validate the type
        ${data}=    Evaluate    json.loads(json.dumps(${response.content}))
        ${type} =    Evaluate    type(${data[0]}).__name__
        Should be Equal     ${type}     dict

Verify Response Data has email
        [Documentation]     Validate API response has 'email' attribute
        [Tags]      Functional
        ${response}=    Get Request         ${users_endpoint}        ${success_statuscode}       ${headers}
        #Verify email attribute available in response json
        Should Have Value In Json       ${response.json()}      $..email
        ${email_id}=        Set Variable        ${response.json()[0]["email"]}
        ${validation_response}=       email_validation     ${email_id}
        #Should be Equal     validation_response      True


Verify entries have similar attributes
        [Documentation]     Validate all the entries in the API response has similar attributes
        [Tags]      Functional
        ${response}=    Get Request         ${users_endpoint}        ${success_statuscode}       ${headers}
        #Getting the response json
        ${data}=        Set Variable        ${response.json()}
        # Getting the length of the response json to verify against each entries of a list
        ${length_data}=     Get Length      ${data}
        #Creating empty list to get the attribute of the first record which will be used to validate with the attributes of the other entries
        ${list_userdata}=      Create List
        FOR     ${content}      IN      @{data[0]}
                Append to List      ${list_userdata}        ${content}
        END

        #Getting the length of the attribute of the first list record to validate against count of attributes in other entries
        ${list_userdata_length}=    Get Length      ${list_userdata}

        #looping through the entries
        FOR     ${index}      IN RANGE     1       ${length_data}
                ${keys}=        Get Dictionary Keys     ${data[${index}]}
                ${keys_length}=    Get Length      ${keys}
                Should be equal     ${list_userdata_length}     ${keys_length}

                # To loop against the  list of attributes in each entry
                FOR         ${i}        IN      @{keys}
                        #validate the key attributes of each record against the key attribute of first record
                        List Should Contain Value         ${list_userdata}          ${i}
                END
        END

Verify HTTP response code when record doesn't exist
        [Documentation]     validate 404 HTTP response code on performing GET with invalid Id
        [Tags]      NonFunctional
        ${response}=    Get Request         ${users_endpoint} /invalid_id       ${notfound_statuscode}      ${headers}

Verify Get without Authentication
        [Documentation]     Perform Get without providing the Bearer token in the query parameter and validate the response
        [Tags]      NonFunctional
        ${response}=    Get Request         ${users_endpoint}        ${success_statuscode}

Verify Post without Authentication
        [Documentation]     Perform Get without providing the Bearer token in the header and validate the response
        [Tags]      NonFunctional
        &{data}=        Create Dictionary       name="test"     email="test@gmail.com"      gender="male"
        ${response}=        POST Request        ${users_endpoint}       ${data}     ${authenticationerror_statuscode}
        ${response_str}=        Convert to String       ${response.content}
        #validation error message from response
        Should be equal      ${response_str}     {"message":"Authentication failed"}


Verify Post with invalid token
        [Documentation]     Perform post with invalid Bearer token in the query parameter and validate the response
        [Tags]      NonFunctional
        ${invalidtoken}=      Get Input       invalidToken
        ${data}=        Get Input       Post_input
        ${response}=        POST Request        ${users_endpoint}?access-token=${invalidtoken}       ${data}        ${authenticationerror_statuscode}
        ${response_str}=        Convert to String       ${response.content}
        #validation error message from response
        Should be equal      ${response_str}     {"message":"Invalid token"}

Verify Post with Authentication
        [Documentation]     Perform Post with valid token in the query parameter and validate the response
        [Tags]      NonFunctional
        ${validtoken}=      Get Input       validToken
        ${data}=        Get Input       Post_input
        ${response}=        POST Request        ${users_endpoint}?access-token=${validtoken}       ${data}       ${Post_successstatus}

Verify HTTP status code-422
        [Documentation]     Perform Post with duplicate entry valid token in the query parameter and validate the response
        [Tags]      NonFunctional
        ${validtoken}=      Get Input       validToken
        ${data}=        Get Input       Post_input
        ${response}=        POST Request        ${users_endpoint}?access-token=${validtoken}       ${data}       ${unprocessed_statuscode}

Verify Non-SSL Rest endpoint behaviour
        [Documentation]     Verify Non-SSL Rest endpoint behaviour and ensure response is success
        [Tags]      NonFunctional
        Create Session      newsession      ${baseurl}      verify=false
        ${response}=    Get Request         ${users_endpoint}        ${success_statuscode}       ${headers}


Logging test results to mongodb
        [Documentation]     Connect to mongodb and update the test status from output.xml file to db
        [Tags]      NonFunctional
        ${mongo}=        Get Input       MongoDb
        ${username}=        set variable        ${mongo["dbusername"]}
        ${password}=        set variable        ${mongo["dbpassword"]}
        ${dbname}=        set variable        ${mongo["dbname"]}
        ${collectionname}=        set variable        ${mongo["collectionname"]}
        ${filename}=        set variable        output.xml
        ${db_results}=        logresults_mongodb      ${username}     ${password}       ${dbname}       ${collectionname}       ${filename}
        log to console      ${db_results}





























