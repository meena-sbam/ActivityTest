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

Get Input
        [Documentation]     Get the token from input.json file and return the token
        [Arguments]     ${input}
        ${json-data}=      Load JSON From File        ./InputData/input.json
        ${data}=         Get From Dictionary       ${json-data}       ${input}
        RETURN      ${data}


Get Request
        [Documentation]     Perform Get request and verify the status
        [Arguments]     ${url}      ${expected_status_code}     ${headers}=${header_content}
        ${response}=    GET On Session      mysession       ${url}       ${headers}     expected_status=${expected_status_code}
        RETURN      ${response}

Post Request
        [Documentation]     Perform Post request and verify the status
        [Arguments]     ${url}     ${data}       ${expected_status_code}     ${headers}=${header_content}
        ${response}=    POST On Session      mysession       ${url}       ${data}       ${headers}     expected_status=${expected_status_code}
        RETURN      ${response}








