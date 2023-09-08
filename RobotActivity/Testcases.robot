*** Settings ***
Documentation    Suite includes the test cases for Functional and Non Functional requirement of gorest api
Library     RequestsLibrary
Library     JSONLibrary
Library     Collections
Library     OperatingSystem
Resource        ./ResourceFile/resource.robot
Test Setup     Session Creation
Test Teardown      Delete All Sessions

*** Variables ***
${users_endpoint}=     /public/v2/users
${AUTH_BEARER}=     Get Input       Token
${headers}=     Create Dictionary       Content-Type=application/json Authorization=Bearer${AUTH_BEARER}

*** Test Cases ***

Verify Response has Pagination
        [Documentation]     Validate the API response has pagination
        [Tags]      Functional
        ${response}=    Get Request         ${users_endpoint}        200      ${headers}
        #Verifying pagination with header availability of 'x-pagination-page'
        should contain      ${response.headers}     x-pagination-page
        #Verifying pagination by performing get request with page details in query parameters
        ${response_with_page}=    Get Request         /public/v2/users?page=1&per_page=10        200

Verify Response has Valid Json Data
        [Documentation]         Validate the response has valid Json data
        [Tags]      Functional
        ${response}=    Get Request         ${users_endpoint}        200      ${headers}
        #verify header content type is json
        should contain      ${response.headers["Content-Type"]}          application/json

        #Using python commands to change json to dictionary and validate the type
        ${data}=    Evaluate    json.loads(json.dumps(${response.content}))
        ${type} =    Evaluate    type(${data[0]}).__name__
        Should be Equal     ${type}     dict

Verify Response Data has email
        [Documentation]     Validate API response has 'email' attribute
        [Tags]      Functional
        ${response}=    Get Request         ${users_endpoint}        200      ${headers}
        #Verify email attribute available in response json
        Should Have Value In Json       ${response.json()}      $..email

Verify entries have similar attributes
        [Documentation]     Validate all the entries in the API response has similar attributes
        [Tags]      Functional
        ${response}=    Get Request         ${users_endpoint}        200      ${headers}
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

Verify HTTP response code-404
        [Documentation]     validate 404 HTTP response code on performing GET with invalid Id
        [Tags]      NonFunctional
        ${response}=    Get Request         ${users_endpoint} /invalid_id       404      ${headers}

Verify Get without Authentication
        [Documentation]     Perform Get without providing the Bearer token in the header and validate the response
        [Tags]      NonFunctional
        ${response}=    Get Request         ${users_endpoint}        200

Verify Post without Authentication
        [Documentation]     Perform Get without providing the Bearer token in the header and validate the response
        [Tags]      NonFunctional
        &{data}=        Create Dictionary       name="test"     email="test@gmail.com"      gender="male"
        ${response}=        POST Request        ${users_endpoint}       ${data}     401
        ${response_str}=        Convert to String       ${response.content}
        Should be equal      ${response_str}     {"message":"Authentication failed"}




























