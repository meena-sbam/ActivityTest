*** Settings ***
Library     RequestsLibrary
Library     JSONLibrary
Library     Collections
Library     OperatingSystem
#Library     HttpLibrary.HTTP
Resource        resource.robot
Test Setup     Session Creation
Test Teardown      Delete All Sessions

*** Variables ***
${url}=     https://gorest.co.in/
${AUTH_BEARER}=     Create Dictionary
${AUTH_BEARER}=     Get Token
${headers}=     Create Dictionary       Content-Type=application/json Authorization=Bearer${AUTH_BEARER}

*** Test Cases ***

Verify Response has Pagination
        ${response}=    Get Request         /public/v2/users        200      ${headers}
        #Verifying pagination with header availability of 'x-pagination-page'
        should contain      ${response.headers}     x-pagination-page
        #Verifying pagination by performing get request with page details in query parameters
        ${response_with_page}=    Get Request         /public/v2/users?page=1&per_page=10        200

Verify Response has Valid Json Data
        ${response}=    Get Request         /public/v2/users        200      ${headers}
        #verify header content type is json
        should contain      ${response.headers["Content-Type"]}          application/json


Verify Response Data has email
        ${response}=    Get Request         /public/v2/users        200      ${headers}
        #Verify email attribute available in response json
        Should Have Value In Json       ${response.json()}      $..email


Verify entries have similar attributes
        ${response}=    Get Request         /public/v2/users        200      ${headers}
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
                log to console      ${keys}

                # To loop against the  list of attributes in each entry
                FOR         ${i}        IN      @{keys}
                        #validate the key attributes of each record against the key attribute of first record
                        List Should Contain Value         ${list_userdata}          ${i}
                END
        END
























