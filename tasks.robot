*** Settings ***
Documentation       Template robot main suite.

Library             RPA.Browser.Selenium    auto_close=${False}
Library             RPA.HTTP
Library             RPA.Excel.Files
Library             RPA.Tables
Library             RPA.PDF
Library             RPA.Dialogs
Library             RPA.FileSystem
Library             RPA.Archive
Library             RPA.Dialogs


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    Input csv file path from user before download
    Add csv details into form


*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Input csv file path from user before download
    Add heading    Provide CSV File Path
    Add text input    CSV    label=CSV File Path
    ${result}=    Run dialog
    Download    ${result.CSV}    overwrite=True
    #Download    https://robotsparebinindustries.com/orders.csv    overwrite=True

Fill the form for ordering Robot
    [Arguments]    ${order}
    Click Button    OK
    Select From List By Value    head    ${order}[Head]
    Click Button    id-body-${order}[Body]
    Input Text    address    ${order}[Address]
    Input Text    xpath://*[@placeholder="Enter the part number for the legs"]    ${order}[Legs]

Submit the form
    [Arguments]    ${order}
    Click Button    preview
    Click Button    order
    ${receipt}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${receipt}    ${OUTPUT_DIR}${/}${order}[Order number].pdf

Take Screenshot
    [Arguments]    ${order}
    Wait Until Page Contains Element    robot-preview-image
    Screenshot    robot-preview-image    ${OUTPUT_DIR}${/}screenshot.png
    Open Pdf    ${OUTPUT_DIR}${/}${order}[Order number].pdf
    ${files}=    Create List
    ...    ${OUTPUT_DIR}${/}${order}[Order number].pdf
    ...    ${OUTPUT_DIR}${/}screenshot.png
    Add Files To Pdf    ${files}    ${OUTPUT_DIR}${/}${order}[Order number].pdf

    Click Button    order-another

Add csv details into form
    ${orders}=    Read table from CSV    orders.csv    header=True

    FOR    ${order}    IN    @{orders}
        Wait Until Keyword Succeeds    3x    2 sec    Fill the form for ordering Robot    ${order}
        Wait Until Keyword Succeeds    4x    2 sec    Submit the form    ${order}
        Wait Until Keyword Succeeds    4x    2 sec    Take Screenshot    ${order}
    END
    Archive Folder With Zip    ${OUTPUT_DIR}${/}    mydocs.zip    include=*.pdf
