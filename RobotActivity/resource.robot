*** Settings ***
Library     RequestsLibrary
Library     JSONLibrary
Library     Collections


*** Variables ***
${baseurl}=     https://gorest.co.in/
${header_content}=     Create Dictionary       Content-Type=application/json

*** Keywords ***

Session Creation
        [Documentation]     Creates Session
        Create Session  mysession      ${baseurl}       verify=true

Get Token
        [Documentation]     Get the token from input.json file and return the token
        ${json-data}=      Load JSON From File        input.json
        ${token}=         Get From Dictionary       ${json-d}       Token
        RETURN      ${token}


Get Request
        [Documentation]     Perform Get request and verify the status
        [Arguments]     ${url}      ${expected_status_code}     ${headers}=${header_content}
         ${response}=    GET On Session      mysession       ${url}       ${headers}
         ${actual_status_code}=      convert to String   ${response.status_code}
         should be equal     ${actual_status_code}      ${expected_status_code}
         RETURN      ${response}





