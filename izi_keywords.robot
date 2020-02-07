*** Settings ***
Library  Selenium2Library
Library  izi_service.py
Library  String

*** Keywords ***
izi get awardId by awardIndex
  [Arguments]  ${awardIndex}
  ${tenderIziId}=  izi знайти на сторінці тендера поле tenderIziId
  ${url}=  Set Variable  ${BROKERS.izi.backendUrl}/tenders/${tenderIziId}/identifiers?awardIndex=${awardIndex}
  ${response}=  izi_service.get  ${url}
  ${statusCode}=  Get Variable Value  ${response.status_code}
  Run Keyword And Return If  '${statusCode}' != '200'  Fail
  ${awardId}=  Get Variable Value  ${response.data}
  [Return]  ${awardId}

izi get tender dateModified
  [Arguments]  ${tenderUaId}
  ${url}=  Set Variable  ${BROKERS.izi.backendUrl}/tenders/${tenderUaId}/dateModified
  ${response}=  izi_service.get  ${url}
  ${statusCode}=  Get Variable Value  ${response.status_code}
  Run Keyword And Return If  '${statusCode}' != '200'  Fail
  ${dateModified}=  Get Variable Value  ${response.data}
  [Return]  ${dateModified}

izi get plan dateModified
  [Arguments]  ${planUaId}
  ${url}=  Set Variable  ${BROKERS.izi.backendUrl}/plans/${planUaId}/dateModified
  ${response}=  izi_service.get  ${url}
  ${statusCode}=  Get Variable Value  ${response.status_code}
  Run Keyword And Return If  '${statusCode}' != '200'  Fail
  ${dateModified}=  Get Variable Value  ${response.data}
  [Return]  ${dateModified}

izi get agreement dateModified
  [Arguments]  ${agreementUaId}
  ${url}=  Set Variable  ${BROKERS.izi.backendUrl}/agreements/${agreementUaId}/dateModified
  ${response}=  izi_service.get  ${url}
  ${statusCode}=  Get Variable Value  ${response.status_code}
  Run Keyword And Return If  '${statusCode}' != '200'  Fail
  ${dateModified}=  Get Variable Value  ${response.data}
  [Return]  ${dateModified}

izi get award docId by docIndex
  [Arguments]  ${awardIndex}  ${docIndex}
  ${tenderIziId}=  izi знайти на сторінці тендера поле tenderIziId
  ${url}=  Set Variable  ${BROKERS.izi.backendUrl}/tenders/${tenderIziId}/identifiers?awardIndex=${awardIndex}&documentIndex=${docIndex}
  ${response}=  izi_service.get  ${url}
  ${statusCode}=  Get Variable Value  ${response.status_code}
  Run Keyword And Return If  '${statusCode}' != '200'  Fail
  ${docId}=  Get Variable Value  ${response.data}
  [Return]  ${docId}

izi get tender docId by docIndex
  [Arguments]  ${docIndex}
  ${tenderIziId}=  izi знайти на сторінці тендера поле tenderIziId
  ${url}=  Set Variable  ${BROKERS.izi.backendUrl}/tenders/${tenderIziId}/identifiers?documentIndex=${docIndex}
  ${response}=  izi_service.get  ${url}
  ${statusCode}=  Get Variable Value  ${response.status_code}
  Run Keyword And Return If  '${statusCode}' != '200'  Fail
  ${docId}=  Get Variable Value  ${response.data}
  [Return]  ${docId}

izi dropdown select option
  [Arguments]  ${dropDownSelector}  ${key}
  ${currentKey}=  Get Value  jquery=${dropDownSelector} .izi-drop-down_content input
  Return From Keyword If  '${currentKey}' == '${key}'
  Click Element  jquery=${dropDownSelector} .izi-drop-down_header
  Sleep  350ms
  Click Element  jquery=${dropDownSelector} .izi-drop-down_content ul li[key="${key}"]
  Sleep  350ms

izi get lotIndex by lotId
  [Arguments]  ${lotId}
  ${index}=  Execute Javascript  return $('lot-tabs a[href*=${lotId}]').index()
  [Return]  ${index}

izi dropdown select option that contains text
  [Arguments]  ${dropDownSelector}  ${text}
  ${selectedOptionIndex}=  Execute Javascript  return $('${dropDownSelector} .izi-drop-down_content ul li.selected').index()
  ${optionToSelectIndex}=  Execute Javascript  return $('${dropDownSelector} .izi-drop-down_content ul li:contains(${text})').index()
  Return From Keyword If  '${selectedOptionIndex}' == '${optionToSelectIndex}'
  Click Element  jquery=${dropDownSelector} .izi-drop-down_header
  Sleep  350ms
  Click Element  jquery=${dropDownSelector} .izi-drop-down_content ul li:eq(${optionToSelectIndex})
  Sleep  350ms

izi checkbox check change
  [Arguments]  ${checkboxSelector}  ${check}=True
  ${isChecked}=  Execute Javascript  return $('${checkboxSelector} label input[type=checkbox]').is(':checked')
  Return From Keyword If  '${check}' == '${isChecked}'
  Click Element  jquery=${checkboxSelector} label
  Sleep  50ms

izi sync tender
  [Arguments]  ${tenderUaId}
  ${url}=  Set Variable  ${BROKERS.izi.backendUrl}/tenders/sync/${tenderUaId}
  ${response}=  izi_service.post  ${url}
  ${statusCode}=  Get Variable Value  ${response.status_code}
  Log  Run sync tender ${tenderUaId}  DEBUG
  Run Keyword And Return If  ${statusCode} < 300  Sleep  2s
  Run Keyword And Return If  ${statusCode} != 404
  ...  Fail  неможливо виконати запит на ручну синхронізацію тендеру, статус ${statusCode} ${url}
  Log  Tender ${tenderUaId} was not found, try to wait for sync
  ${passed}=  Run Keyword And Return Status
  ...           Wait Until Keyword Succeeds
  ...             20m  1s
  ...             izi get tender dateModified  ${tenderUaId}
  Run Keyword Unless  ${passed}
  ...  Fail  Couldn't find tender ${tenderUaId}

izi sync plan
  [Arguments]  ${planUaId}
  ${url}=  Set Variable  ${BROKERS.izi.backendUrl}/plans/sync/${planUaId}
  ${response}=  izi_service.post  ${url}
  ${statusCode}=  Get Variable Value  ${response.status_code}
  Log  Run sync plan ${planUaId}  DEBUG
  Run Keyword And Return If  ${statusCode} < 300  Sleep  2s
  Run Keyword And Return If  ${statusCode} != 404
  ...  Fail  неможливо виконати запит на ручну синхронізацію плану, статус ${statusCode} ${url}
  Log  Plan ${planUaId} was not found, try to wait for sync
  ${passed}=  Run Keyword And Return Status
  ...           Wait Until Keyword Succeeds
  ...             20m  1s
  ...             izi get plan dateModified  ${planUaId}
  Run Keyword Unless  ${passed}
  ...  Fail  Couldn't find plan ${planUaId}

izi sync agreement
  [Arguments]  ${agreementUaId}
  ${url}=  Set Variable  ${BROKERS.izi.backendUrl}/agreements/sync/${agreementUaId}
  ${response}=  izi_service.post  ${url}
  ${statusCode}=  Get Variable Value  ${response.status_code}
  Log  Run sync agreement ${agreementUaId}  DEBUG
  Run Keyword And Return If  ${statusCode} < 300  Sleep  2s
  Run Keyword And Return If  ${statusCode} != 404
  ...  Fail  неможливо виконати запит на ручну синхронізацію угоди, статус ${statusCode} ${url}
  Log  Agreement ${agreementUaId} was not found, try to wait for sync
  ${passed}=  Run Keyword And Return Status
  ...           Wait Until Keyword Succeeds
  ...             20m  1s
  ...             izi get agreement dateModified  ${agreementUaId}
  Run Keyword Unless  ${passed}
  ...  Fail  Couldn't find agreement ${agreementUaId}

izi get page lots count
  ${lotsCount}=  Execute Javascript  return $('lot-tabs .lot-tabs__tab').length
  [Return]  ${lotsCount}

izi get tenderJson by tenderUaId
  [Arguments]  ${tenderUaId}
  ${url}=  Set Variable  ${BROKERS.izi.backendUrl}/tenders/${tenderUaId}
  ${response}=  izi_service.get  ${url}
  [Return]  ${response.data}

izi convert izi date to prozorro date
  [Arguments]  ${dateFieldText}
  &{results}  Execute Javascript  return (()=>{let [dateString, day = "", month = "", year = "", time = ""] = "${dateFieldText}".match(/^\\D*(\\d{1,2})\\.(\\d{1,2})\\.(\\d{4})(?:\\s(\\d{1,2}:\\d{1,2}))?$/) || []; return {day, month, year, time}})()
  ${date}=  Convert To String  ${results.year}-${results.month}-${results.day} ${results.time}
  ${result}=  izi_service.convert_dtstring_to_isoformat  ${date}
  [Return]  ${result}

izi convert izi number to prozorro number
  [Arguments]  ${numberTextField}
  ${number}  Execute Javascript  return (()=> +(("${numberTextField}".match(/^\\D*(\\d*[\\s,\\d\\.]*).*$/) || [])[1] || "").replace(/\\s/g,'').replace(/,/g, '.').replace('.00', '') || 0)()
  [Return]  ${number}

izi find objectId element value
  [Arguments]  ${objectId}  ${wrapperElSelector}  ${elThatHasObjectIdSelector}  ${elThatHasValueSelector}
  ${value}=  Execute Javascript  return $("${wrapperElSelector}").has("${elThatHasObjectIdSelector}"+":contains("+"${objectId}"+")").find("${elThatHasValueSelector}").not(':empty').first().text().trim() || null
  [Return]  ${value}

izi find objectId element attribute
  [Arguments]  ${attribute}  ${objectId}  ${wrapperElSelector}  ${elThatHasObjectIdSelector}  ${elThatHasValueSelector}
  ${value}=  Execute Javascript  return $("${wrapperElSelector}").has("${elThatHasObjectIdSelector}"+":contains("+"${objectId}"+")").find("${elThatHasValueSelector}[${attribute}]").first().attr("${attribute}") || null
  [Return]  ${value}

izi перейти на сторінку пошуку
  [Arguments]  ${searchText}
  Go to  ${BROKERS['izi'].homepage}/tenders?searchText=${searchText}
  Wait Until Page Contains Element  css=search-results  15
  Sleep  500ms

izi чи я на сторінці тендеру ${tender_uaid}
  ${currentPageTenderCode}=  Execute Javascript  return $('tender[tendercode]').attr('tendercode')
  Return From Keyword If  '${currentPageTenderCode}' == '${tender_uaid}'  TRUE
  Return From Keyword  FALSE

izi перейти на сторінку тендеру
  [Arguments]  ${tender_uaid}
  izi sync tender  ${tender_uaid}
  ${isAmOnPage}=  izi чи я на сторінці тендеру ${tender_uaid}
  Run Keyword If  '${isAmOnPage}' == 'FALSE'  izi знайти тендер та перейти на сторінку  ${tender_uaid}
  Sleep  2s
  izi bid-submit-form close submit-form by clicking X
  ${factTenderDateModified}=  izi get tender dateModified  ${tender_uaid}
  ${factTenderDateModified}=  Fetch From Left  ${factTenderDateModified}  .
  ${pageTenderDateModified}=  Execute Javascript  return $('tender[datemodified]').attr('datemodified')
  ${pageTenderDateModified}=  Fetch From Left  ${pageTenderDateModified}  .
  Log  tender modified date="${factTenderDateModified}"  DEBUG
  Log  page tender modified date="${pageTenderDateModified}"  DEBUG
  Return From Keyword If  '${factTenderDateModified}' == '${pageTenderDateModified}'
  Log  tender was modified, reloading page....
  ${isLotTender}=  Execute Javascript  return !!$('lot-tabs').length
  Run Keyword If  '${isLotTender}' == 'True'  izi обрати лот 0
  Reload Page
  Wait Until Page Contains Element  css=tender  15
  Sleep  500ms

izi знайти тендер та перейти на сторінку
  [Arguments]  ${tender_uaid}
  izi перейти на сторінку пошуку  searchText=${tender_uaid}
  Sleep  1s
  Click Element  css=search-results tender-info:first-child .tender-info__footer a
  Wait Until Page Contains  ${tender_uaid}  15

izi знайти на сторінці тендера поле title
  ${value}=  Execute Javascript  return $('tender-lot-description:first [titleukr]').text().trim()
  [Return]  ${value}

izi знайти на сторінці тендера поле title_en
  ${value}=  Execute Javascript  return $('tender-lot-description:first [titleen]').text().trim()
  [Return]  ${value}

izi знайти на сторінці тендера поле title_ru
  ${value}=  Execute Javascript  return $('tender-lot-description:first [titleru]').text().trim()
  [Return]  ${value}

izi знайти на сторінці тендера поле description
  ${value}=  Execute Javascript  return $('tender-lot-description:first [titleukr]').next('p').text().trim()
  [Return]  ${value}

izi знайти на сторінці тендера поле description_en
  ${value}=  Execute Javascript  return $('tender-lot-description:first [titleen]').next('p').text().trim()
  [Return]  ${value}

izi знайти на сторінці тендера поле description_ru
  ${value}=  Execute Javascript  return $('tender-lot-description:first [titleru]').next('p').text().trim()
  [Return]  ${value}

izi знайти на сторінці тендера поле value.amount
  Sleep  3
  ${numberTextField}=  Execute Javascript  return $(".tender-details__price-val").first().text().trim()
  ${value}=  izi convert izi number to prozorro number  ${numberTextField}
  [Return]  ${value}

izi знайти на сторінці тендера поле value.valueAddedTaxIncluded
  ${isTaxIncluded}=  Execute Javascript  return $(".tender-details__price-vat").first().text().trim() == "з ПДВ"
  [Return]  ${isTaxIncluded}

izi знайти на сторінці тендера поле tenderID
  ${value}=  Get Text  jquery=.tender-info-notes:not(.mobile) ul li:first-child span
  ${value}=  Convert To String  ${value}
  [Return]  ${value}

izi знайти на сторінці тендера поле originId
  ${value}=  Execute Javascript  return $('tender[originid]').attr('originid')
  [Return]  ${value}

izi знайти на сторінці тендера поле tenderIziId
  ${value}=  Execute Javascript  return $('tender[tenderiziid]').attr('tenderiziid')
  [Return]  ${value}

izi знайти на сторінці тендера поле procuringEntity.name
  ${value}=  Execute Javascript  return $('[procuringentityname]').attr('procuringentityname')
  [Return]  ${value}

izi знайти на сторінці тендера поле procuringEntity.identifier.legalName
  ${value}=  Execute Javascript  return $('[procuringentitylegalname]').attr('procuringentitylegalname')
  [Return]  ${value}

izi get procuringEntity adress string
  ${value}=  Execute Javascript  return $('.tender-details__more-info dl:has(dt:contains(Адреса)) dd').text()
  [Return]  ${value}

izi знайти на сторінці тендера поле procuringEntity.address.countryName
  ${adressString}=  izi get procuringEntity adress string
  ${value}=  izi get countryName from iziAddressString
  ...  addressString=${adressString}
  [Return]  ${value}

izi знайти на сторінці тендера поле procuringEntity.address.locality
  ${adressString}=  izi get procuringEntity adress string
  ${value}=  izi get locality from iziAddressString
  ...  addressString=${adressString}
  [Return]  ${value}

izi знайти на сторінці тендера поле procuringEntity.address.postalCode
  ${adressString}=  izi get procuringEntity adress string
  ${value}=  izi get postalCode from iziAddressString
  ...  addressString=${adressString}
  [Return]  ${value}

izi знайти на сторінці тендера поле procuringEntity.address.region
  ${adressString}=  izi get procuringEntity adress string
  ${value}=  izi get region from iziAddressString
  ...  addressString=${adressString}
  [Return]  ${value}

izi знайти на сторінці тендера поле procuringEntity.address.streetAddress
  ${adressString}=  izi get procuringEntity adress string
  ${value}=  izi get streetAddress from iziAddressString
  ...  addressString=${adressString}
  [Return]  ${value}

izi знайти на сторінці тендера поле procuringEntity.contactPoint.url
  ${value}=  Execute Javascript  return $('tender-details .tender-details__more-info dl:has(dt:contains(Сайт:)) dd').text().trim()
  [Return]  ${value}

izi знайти на сторінці тендера поле procuringEntity.identifier.scheme
  ${value}=  Execute Javascript  return $('tender-details .tender-details__more-info dl:has(strong:contains(Схема Ідентифікації:)) dd').text().trim()
  [Return]  ${value}

izi знайти на сторінці тендера поле procuringEntity.identifier.id
  ${value}=  Execute Javascript  return $('tender-details .tender-details__more-info dl:has(dt:contains(Код ЄДРПОУ:)) dd').text().trim()
  [Return]  ${value}

izi знайти на сторінці тендера поле procuringEntity.contactPoint.name
  ${value}=  Execute Javascript  return $('tender-details .tender-details__more-info dl:has(dt:contains(Контактна особа:)) dd').text().trim()
  [Return]  ${value}

izi знайти на сторінці тендера поле procuringEntity.contactPoint.telephone
  ${value}=  Execute Javascript  return $('tender-details .tender-details__more-info dl:has(dt:contains(Телефон:)) dd:first').text().trim()
  [Return]  ${value}

izi знайти на сторінці тендера поле tenderPeriod.startDate
  ${value}=  Execute Javascript  return $('tender-periods-diagram .tender-periods-diagram__item p:contains(Подання пропозицій)+p span:eq(0)').text()
  ${value}=  izi convert izi date to prozorro date  ${value}
  [Return]  ${value}

izi знайти на сторінці тендера поле tenderPeriod.endDate
  ${value}=  Execute Javascript  return $('tender-periods-diagram .tender-periods-diagram__item p:contains(Подання пропозицій)+p span:eq(1)').text()
  ${value}=  izi convert izi date to prozorro date  ${value}
  [Return]  ${value}

izi знайти на сторінці тендера поле enquiryPeriod.startDate
  ${stepName}=  Run Keyword If  '${MODE}' == 'belowThreshold'  Set Variable  Період уточнень
  ...  ELSE  Set Variable  Подання пропозицій
  ${value}=  Execute Javascript  return $('tender-periods-diagram .tender-periods-diagram__item p:contains(${stepName})+p span:eq(0)').text()
  ${value}=  izi convert izi date to prozorro date  ${value}
  [Return]  ${value}

izi знайти на сторінці тендера поле enquiryPeriod.endDate
  ${stepName}=  Run Keyword If  '${MODE}' == 'belowThreshold'  Set Variable  Період уточнень
  ...  ELSE  Set Variable  Подання пропозицій
  ${value}=  Execute Javascript  return $('tender-periods-diagram .tender-periods-diagram__item p:contains(${stepName})+p span:eq(1)').text()
  ${value}=  izi convert izi date to prozorro date  ${value}
  [Return]  ${value}

izi знайти на сторінці тендера поле minimalStep.amount
  ${lotsCount}=  izi get page lots count
  Run Keyword And Return If  ${lotsCount} > 0  izi знайти на сторінці лотів мінімальний minimalStep.amount
  ${numberTextField}=  Get Text  jquery=tender tender-lot-info:first notes li strong:contains(Мінімальний крок аукціону:) + span
  ${value}=  izi convert izi number to prozorro number  ${numberTextField}
  [Return]  ${value}

izi get lot minimalStep string
  ${minimalStepString}=  Execute Javascript  return $('.tender-lot tender-lot-info notes li:has(strong:contains(Мінімальний крок аукціону:)) span').text().trim()
  [Return]  ${minimalStepString}

izi знайти на сторінці лотів мінімальний minimalStep.amount
  ${minAmount}=  Set Variable  None
  ${lotsCount}=  izi get page lots count
  :FOR  ${index}  IN RANGE  ${lotsCount}
  \  ${lotMinAmount}=  izi знайти на сторінці лоту ${index} поле minimalStep.amount
  \  ${minAmount}=  Run Keyword If  ${index} == 0
  ...  Set Variable  ${lotMinAmount}
  ...  ELSE IF  ${lotMinAmount} < ${minAmount}
  ...  Set Variable  ${lotMinAmount}
  ...  ELSE  Set Variable  ${minAmount}
  [Return]  ${minAmount}

izi знайти на сторінці лоту ${index} поле minimalStep.amount
  izi обрати лот ${index}
  ${minimalStepString}=  izi get lot minimalStep string
  ${value}=  izi convert izi number to prozorro number  ${minimalStepString}
  [Return]  ${value}

izi знайти на сторінці лоту ${index} поле minimalStep.currency
  izi обрати лот ${index}
  ${minimalStepString}=  izi get lot minimalStep string
  ${currency}=  Execute Javascript  return "${minimalStepString}".split(" ").slice(-3).shift()
  ${value}=  convert_izi_string_to_prozorro_string  ${currency}
  [Return]  ${value}

izi знайти на сторінці лоту ${index} поле minimalStep.valueAddedTaxIncluded
  izi обрати лот ${index}
  ${isTaxIncluded}=  Execute Javascript  return !!$('.tender-lot tender-lot-info notes li:has(strong:contains(Мінімальний крок аукціону:)) span:contains(з ПДВ)').length > 0
  [Return]  ${isTaxIncluded}

izi знайти на сторінці тендера поле awards[${awardIndex}].complaintPeriod.endDate
  ${awardId}=  izi get awardId by awardIndex
  ...  awardIndex=${awardIndex}
  ${status}=  Run Keyword And Return Status  izi claim-submit-form open form  ${awardIndex}
  Run Keyword And Return If  '${status}'=='False'  izi знайти на сторінці лоту поле award-complaintPeriod-endDate  ${tender}  ${awardIndex}
  izi dropdown select option  key=${awardId}  dropDownSelector=claims award-pretense-create award-select
  ${value}=  Execute Javascript   return $('award-pretense-create form-message').attr('complaintPeriodEndDate')
  [Return]  ${value}

izi знайти на сторінці лоту поле award-complaintPeriod-endDate
  [Arguments]  ${tender}  ${awardIndex}
  ${lotId}=  Get Variable Value  ${tender.data.awards[${awardIndex}].lotID}  ${None}
  ${lotIndex}=  izi get lotIndex by lotId  ${lotId}
  Run Keyword If  '${lotId}'!='${None}'  izi обрати лот ${lotIndex}
  ${value}=  Execute Javascript   return $('.tender-lot-status__complain-period p:first').attr('complaintPeriodEndDate')
  [Return]  ${value}

izi знайти на сторінці тендера поле complaintPeriod.endDate
  ${value}=  Execute Javascript  return $('complaints tender-pretense-create .pretense-create__info').text().trim().split(' ').slice(-2).join(' ')
  ${value}=  Split String  ${value}  24
  [Return]  ${value}

izi знайти на сторінці тендера поле status
  ${value}=  Execute Javascript  return $('tender[tendercode]').attr('status')
  ${value}=  Convert To String  ${value}
  [Return]  ${value}

izi знайти на сторінці тендера поле cause
  ${value}=  Execute Javascript  return $('[cause]').attr("cause")
  ${value}=  Convert To String  ${value}
  [Return]  ${value}

izi знайти на сторінці тендера поле causeDescription
  ${value}=  Get Text  jquery=tender .tender-info-notes:eq(1) ul li:last span
  ${value}=  Convert To String  ${value}
  [Return]  ${value}

izi знайти на сторінці тендера поле value.currency
  Sleep  3
  ${value}=  Execute Javascript  return $(".tender-details__price-curr").text().trim()
  ${value}=  get_prozorro_curr_by_izi_curr  ${value}
  [Return]  ${value}

izi знайти на сторінці тендера поле description предмету ${item_id}
  ${value}=  izi find objectId element value  objectId=${item_id}
  ...  wrapperElSelector=.items-info .items-info__row
  ...  elThatHasObjectIdSelector=.items-info__name .items-info__name-desc
  ...  elThatHasValueSelector=.items-info__name .items-info__name-desc
  [Return]  ${value}

izi знайти на сторінці тендера поле title нецінового показника ${feature_id}
  ${value}=  izi find objectId element value  objectId=${feature_id}
  ...  wrapperElSelector=winner-criterias .winner-criterias__row
  ...  elThatHasObjectIdSelector=.winner-criterias__name
  ...  elThatHasValueSelector=.winner-criterias__name
  [Return]  ${value}

izi знайти на сторінці тендера поле deliveryDate.endDate предмету ${item_id}
  ${value}=  izi find objectId element value
  ...  objectId=${item_id}
  ...  wrapperElSelector=.items-info .items-info__row
  ...  elThatHasObjectIdSelector=.items-info__name
  ...  elThatHasValueSelector=.items-info__popup p:contains("Строк виконання робіт/надання послуг") span:last, .items-info__popup p:contains("Період доставки") span:last
  ${value}=  izi convert izi date to prozorro date  ${value}
  [Return]  ${value}

izi знайти на сторінці тендера поле deliveryDate.startDate предмету ${item_id}
  ${value}=  izi find objectId element value
  ...  objectId=${item_id}
  ...  wrapperElSelector=.items-info .items-info__row
  ...  elThatHasObjectIdSelector=.items-info__name
  ...  elThatHasValueSelector=.items-info__popup p:contains("Строк виконання робіт/надання послуг") span:first, .items-info__popup p:contains("Період доставки") span:first
  ${value}=  izi convert izi date to prozorro date  ${value}
  [Return]  ${value}

izi знайти на сторінці тендера поле items[${item_index}].deliveryDate.startDate
  ${value}=  Execute Javascript  return $('.items-info .items-info__row:eq(${item_index}) .items-info__popup p:contains("Строк виконання робіт/надання послуг") span:first, .items-info .items-info__row:eq(${item_index}) .items-info__popup p:contains("Період доставки") span:first').text()
  ${value}=  izi convert izi date to prozorro date  ${value}
  [Return]  ${value}

izi знайти на сторінці тендера поле items[${item_index}].deliveryDate.endDate
  ${value}=  Execute Javascript  return $('.items-info .items-info__row:eq(${item_index}) .items-info__popup p:contains("Строк виконання робіт/надання послуг") span:last, .items-info .items-info__row:eq(${item_index}) .items-info__popup p:contains("Період доставки") span:last').text()
  ${value}=  izi convert izi date to prozorro date  ${value}
  [Return]  ${value}

izi знайти на сторінці тендера поле items[${item_index}].deliveryDate.endDate предмету ${item_id}
  ${value}=  izi find objectId element value
  ...  objectId=${item_id}
  ...  wrapperElSelector=.items-info .items-info__row
  ...  elThatHasObjectIdSelector=.items-info__name
  ...  elThatHasValueSelector=.items-info__popup p:contains("Строк виконання робіт/надання послуг") span:last, .items-info__popup p:contains("Період доставки") span:last
  ${value}=  izi convert izi date to prozorro date  ${value}
  [Return]  ${value}

izi знайти на сторінці тендера поле deliveryAddress.region предмету ${item_id}
  ${value}=  izi find objectId element value  objectId=${item_id}
  ...  wrapperElSelector=.items-info .items-info__row
  ...  elThatHasObjectIdSelector=.items-info__name
  ...  elThatHasValueSelector=.items-info__popup p:contains(Місце доставки:) span
  ${value}=  izi get region from iziAddressString
  ...  addressString=${value}
  [Return]  ${value}

izi знайти на сторінці тендера поле deliveryAddress.countryName предмету ${item_id}
  ${value}=  izi find objectId element value  objectId=${item_id}
  ...  wrapperElSelector=.items-info .items-info__row
  ...  elThatHasObjectIdSelector=.items-info__name
  ...  elThatHasValueSelector=.items-info__popup p:contains(Місце доставки:) span
  ${value}=  izi get countryName from iziAddressString
  ...  addressString=${value}
  [Return]  ${value}

izi знайти на сторінці тендера поле deliveryAddress.countryName_ru предмету ${item_id}
  ${value}=  izi find objectId element value  objectId=${item_id}
  ...  wrapperElSelector=.items-info .items-info__row
  ...  elThatHasObjectIdSelector=.items-info__name
  ...  elThatHasValueSelector=.items-info__popup p:contains(Місце доставки:) span
  ${value}=  izi get countryName_ru from iziAddressString
  ...  addressString=${value}
  [Return]  ${value}


izi знайти на сторінці лоту ${lotIndex} поле deliveryAddress.countryName_ru предмету ${item_id}
  izi обрати лот ${lotIndex}
  ${value}=  izi find objectId element value  objectId=${item_id}
  ...  wrapperElSelector=.items-info .items-info__row
  ...  elThatHasObjectIdSelector=.items-info__name
  ...  elThatHasValueSelector=.items-info__popup p:contains(Місце доставки:) span
  ${value}=  izi get countryName_ru from iziAddressString
  ...  addressString=${value}
  [Return]  ${value}

izi знайти на сторінці тендера поле deliveryAddress.countryName_en предмету ${item_id}
  ${value}=  izi find objectId element value  objectId=${item_id}
  ...  wrapperElSelector=.items-info .items-info__row
  ...  elThatHasObjectIdSelector=.items-info__name
  ...  elThatHasValueSelector=.items-info__popup p:contains(Місце доставки:) span
  ${value}=  izi get countryName_en from iziAddressString
  ...  addressString=${value}
  [Return]  ${value}

izi знайти на сторінці лоту ${lotIndex} поле deliveryAddress.countryName_en предмету ${item_id}
  izi обрати лот ${lotIndex}
  ${value}=  izi find objectId element value  objectId=${item_id}
  ...  wrapperElSelector=.items-info .items-info__row
  ...  elThatHasObjectIdSelector=.items-info__name
  ...  elThatHasValueSelector=.items-info__popup p:contains(Місце доставки:) span
  ${value}=  izi get countryName_en from iziAddressString
  ...  addressString=${value}
  [Return]  ${value}

izi знайти на сторінці тендера поле deliveryAddress.postalCode предмету ${item_id}
  ${value}=  izi find objectId element value  objectId=${item_id}
  ...  wrapperElSelector=.items-info .items-info__row
  ...  elThatHasObjectIdSelector=.items-info__name
  ...  elThatHasValueSelector=.items-info__popup p:contains(Місце доставки:) span
  ${value}=  izi get postalCode from iziAddressString
  ...  addressString=${value}
  [Return]  ${value}

izi знайти на сторінці тендера поле deliveryAddress.locality предмету ${item_id}
  ${value}=  izi find objectId element value  objectId=${item_id}
  ...  wrapperElSelector=.items-info .items-info__row
  ...  elThatHasObjectIdSelector=.items-info__name
  ...  elThatHasValueSelector=.items-info__popup p:contains(Місце доставки:) span
  ${value}=  izi get locality from iziAddressString
  ...  addressString=${value}
  [Return]  ${value}

izi знайти на сторінці тендера поле deliveryAddress.streetAddress предмету ${item_id}
  ${value}=  izi find objectId element value  objectId=${item_id}
  ...  wrapperElSelector=.items-info .items-info__row
  ...  elThatHasObjectIdSelector=.items-info__name
  ...  elThatHasValueSelector=.items-info__popup p:contains(Місце доставки:) span
  ${value}=  izi get streetAddress from iziAddressString
  ...  addressString=${value}
  [Return]  ${value}

izi знайти на сторінці тендера поле classification.scheme предмету ${item_id}
  ${value}=  izi find objectId element value  objectId=${item_id}
  ...  wrapperElSelector=.items-info .items-info__row
  ...  elThatHasObjectIdSelector=.items-info__name
  ...  elThatHasValueSelector=.items-info__classification-scheme:eq(0)
  [Return]  ${value}

izi знайти на сторінці тендера поле classification.id предмету ${item_id}
  ${value}=  izi find objectId element value  objectId=${item_id}
  ...  wrapperElSelector=.items-info .items-info__row
  ...  elThatHasObjectIdSelector=.items-info__name
  ...  elThatHasValueSelector=.items-info__classification-id:eq(0)
  [Return]  ${value}

izi знайти на сторінці тендера поле classification.description предмету ${item_id}
  ${value}=  izi find objectId element value  objectId=${item_id}
  ...  wrapperElSelector=.items-info .items-info__row
  ...  elThatHasObjectIdSelector=.items-info__name
  ...  elThatHasValueSelector=.items-info__classification-descr:eq(0)
  [Return]  ${value}

izi знайти на сторінці тендера поле quantity предмету ${item_id}
  ${value}=  izi find objectId element value  objectId=${item_id}
  ...  wrapperElSelector=.items-info .items-info__row
  ...  elThatHasObjectIdSelector=.items-info__name
  ...  elThatHasValueSelector=.items-info__number span:eq(0)
  ${value}=  Convert To Number  ${value}
  [Return]  ${value}

izi знайти на сторінці тендера поле unit.name предмету ${item_id}
  ${value}=  izi find objectId element value  objectId=${item_id}
  ...  wrapperElSelector=.items-info .items-info__row
  ...  elThatHasObjectIdSelector=.items-info__name
  ...  elThatHasValueSelector=.items-info__number span:eq(1)
  [Return]  ${value}

izi знайти на сторінці тендера поле unit.code предмету ${item_id}
  ${attribute}=  Set Variable  przItemUnitCode
  ${value}=  izi find objectId element attribute  attribute=${attribute}  objectId=${item_id}
  ...  wrapperElSelector=.items-info .items-info__row
  ...  elThatHasObjectIdSelector=.items-info__name
  ...  elThatHasValueSelector=.items-info__uname
  [Return]  ${value}

izi знайти на сторінці тендера поле description нецінового показника ${feature_id}
  ${value}=  izi find objectId element value  objectId=${feature_id}
  ...  wrapperElSelector=winner-criterias .winner-criterias__row
  ...  elThatHasObjectIdSelector=.winner-criterias__name
  ...  elThatHasValueSelector=.winner-criterias__name-col info-popup span div span
  [Return]  ${value}

izi обрати лот ${index}
  Click Element  jquery=lot-tabs .lot-tabs__tab:eq(${index})
  Sleep  100ms

izi знайти на сторінці лоту поле lots[${index}].${field}
  Run Keyword And Return  izi знайти на сторінці лоту ${index} поле ${field}

izi знайти на сторінці лоту ${index} поле title
  izi обрати лот ${index}
  ${value}=  Get Text  css=tender-lot .tender-lot-description__title
  [Return]  ${value}

izi знайти на сторінці лоту ${index} поле description
  izi обрати лот ${index}
  ${value}=  Get Text  jquery=tender-lot tender-lot-description p:first
  [Return]  ${value}

izi get lot budget string
  ${budgetString}=  Execute Javascript  return $('.tender-lot tender-lot-info notes li:has(strong:contains(Бюджет лоту:)) span').text().trim()
  [Return]  ${budgetString}

izi знайти на сторінці лоту ${index} поле value.amount
  izi обрати лот ${index}
  ${budgetString}=  izi get lot budget string
  ${value}=  izi convert izi number to prozorro number  ${budgetString}
  [Return]  ${value}

izi знайти на сторінці лоту ${index} поле value.currency
  izi обрати лот ${index}
  ${budgetString}=  izi get lot budget string
  ${currencyField}=  Execute Javascript  return "${budgetString}".split(" ").slice(-3).shift()
  ${value}=  convert_izi_string_to_prozorro_string  ${currencyField}
  [Return]  ${value}

izi знайти на сторінці лоту ${index} поле value.valueAddedTaxIncluded
  izi обрати лот ${index}
  ${isTaxIncluded}=  Execute Javascript  return !!$('.tender-lot tender-lot-info notes li:has(strong:contains(Бюджет лоту:)) span:contains(з ПДВ)').length > 0
  [Return]  ${isTaxIncluded}

izi знайти на сторінці лоту ${index} поле description предмету ${item_id}
  izi обрати лот ${index}
  ${value}=  izi find objectId element value  objectId=${item_id}
  ...  wrapperElSelector=.items-info .items-info__row
  ...  elThatHasObjectIdSelector=.items-info__name
  ...  elThatHasValueSelector=.items-info__name-desc
  [Return]  ${value}

izi знайти на сторінці лоту ${index} поле deliveryDate.startDate предмету ${item_id}
  izi обрати лот ${index}
  ${value}=  izi find objectId element value
  ...  objectId=${item_id}
  ...  wrapperElSelector=.items-info .items-info__row
  ...  elThatHasObjectIdSelector=.items-info__name
  ...  elThatHasValueSelector=.items-info__popup p:contains("Строк виконання робіт/надання послуг") span:first, .items-info__popup p:contains("Період доставки") span:first
  ${value}=  izi convert izi date to prozorro date  ${value}
  [Return]  ${value}


izi знайти на сторінці лоту ${index} поле deliveryDate.endDate предмету ${item_id}
  izi обрати лот ${index}
  ${value}=  izi find objectId element value
  ...  objectId=${item_id}
  ...  wrapperElSelector=.items-info .items-info__row
  ...  elThatHasObjectIdSelector=.items-info__name
  ...  elThatHasValueSelector=.items-info__popup p:contains("Строк виконання робіт/надання послуг") span:last, .items-info__popup p:contains("Період доставки") span:last
  ${value}=  izi convert izi date to prozorro date  ${value}
  [Return]  ${value}


izi знайти на сторінці лоту ${index} поле deliveryAddress.region предмету ${item_id}
  izi обрати лот ${index}
  ${value}=  izi find objectId element value  objectId=${item_id}
  ...  wrapperElSelector=.items-info .items-info__row
  ...  elThatHasObjectIdSelector=.items-info__name
  ...  elThatHasValueSelector=.items-info__popup p:contains(Місце доставки) span
  ${value}=  izi get region from iziAddressString
  ...  addressString=${value}
  [Return]  ${value}


izi знайти на сторінці лоту ${index} поле deliveryAddress.locality предмету ${item_id}
  izi обрати лот ${index}
  ${value}=  izi find objectId element value  objectId=${item_id}
  ...  wrapperElSelector=.items-info .items-info__row
  ...  elThatHasObjectIdSelector=.items-info__name
  ...  elThatHasValueSelector=.items-info__popup p:contains(Місце доставки) span

  ${value}=  izi get locality from iziAddressString
  ...  addressString=${value}
  [Return]  ${value}


izi знайти на сторінці лоту ${index} поле deliveryAddress.countryName предмету ${item_id}
  izi обрати лот ${index}
  ${value}=  izi find objectId element value  objectId=${item_id}
  ...  wrapperElSelector=.items-info .items-info__row
  ...  elThatHasObjectIdSelector=.items-info__name
  ...  elThatHasValueSelector=.items-info__popup p:contains(Місце доставки:) span
  ${value}=  izi get countryName from iziAddressString
  ...  addressString=${value}
  [Return]  ${value}

izi знайти на сторінці лоту ${index} поле deliveryAddress.postalCode предмету ${item_id}
  izi обрати лот ${index}
  ${value}=  izi find objectId element value  objectId=${item_id}
  ...  wrapperElSelector=.items-info .items-info__row
  ...  elThatHasObjectIdSelector=.items-info__name
  ...  elThatHasValueSelector=.items-info__popup p:contains(Місце доставки:) span
  ${value}=  izi get postalCode from iziAddressString
  ...  addressString=${value}
  [Return]  ${value}

izi знайти на сторінці лоту ${index} поле deliveryAddress.streetAddress предмету ${item_id}
  izi обрати лот ${index}
  ${value}=  izi find objectId element value  objectId=${item_id}
  ...  wrapperElSelector=.items-info .items-info__row
  ...  elThatHasObjectIdSelector=.items-info__name
  ...  elThatHasValueSelector=.items-info__popup p:contains(Місце доставки:) span
  ${value}=  izi get streetAddress from iziAddressString
  ...  addressString=${value}
  [Return]  ${value}

izi знайти на сторінці лоту ${index} поле classification.scheme предмету ${item_id}
  izi обрати лот ${index}
  ${value}=  izi find objectId element value  objectId=${item_id}
  ...  wrapperElSelector=.items-info .items-info__row
  ...  elThatHasObjectIdSelector=.items-info__name
  ...  elThatHasValueSelector=.items-info__classification-scheme:eq(0)
  [Return]  ${value}

izi знайти на сторінці лоту ${index} поле classification.id предмету ${item_id}
  izi обрати лот ${index}
  ${value}=  izi find objectId element value  objectId=${item_id}
  ...  wrapperElSelector=.items-info .items-info__row
  ...  elThatHasObjectIdSelector=.items-info__name
  ...  elThatHasValueSelector=.items-info__classification-id:eq(0)
  [Return]  ${value}

izi знайти на сторінці лоту ${index} поле classification.description предмету ${item_id}
  izi обрати лот ${index}
  ${value}=  izi find objectId element value  objectId=${item_id}
  ...  wrapperElSelector=.items-info .items-info__row
  ...  elThatHasObjectIdSelector=.items-info__name
  ...  elThatHasValueSelector=.items-info__classification-descr:eq(0)
  [Return]  ${value}

izi знайти на сторінці лоту ${index} поле unit.name предмету ${item_id}
  izi обрати лот ${index}
  ${value}=  izi find objectId element value  objectId=${item_id}
  ...  wrapperElSelector=.items-info .items-info__row
  ...  elThatHasObjectIdSelector=.items-info__name
  ...  elThatHasValueSelector=.items-info__number span:eq(1)
  [Return]  ${value}

izi знайти на сторінці лоту ${index} поле unit.code предмету ${item_id}
  izi обрати лот ${index}
  ${value}=  izi find objectId element value  objectId=${item_id}
  ...  wrapperElSelector=.items-info .items-info__row
  ...  elThatHasObjectIdSelector=.items-info__name
  ...  elThatHasValueSelector=.items-info__number span:eq(2)
  [Return]  ${value}

izi знайти на сторінці лоту ${index} поле quantity предмету ${item_id}
  izi обрати лот ${index}
  ${value}=  izi find objectId element value  objectId=${item_id}
  ...  wrapperElSelector=.items-info .items-info__row
  ...  elThatHasObjectIdSelector=.items-info__name
  ...  elThatHasValueSelector=.items-info__number span:eq(0)
  ${value}=  Convert To Number  ${value}
  [Return]  ${value}

izi знайти на сторінці лоту ${index} поле title нецінового показника ${feature_id}
  izi обрати лот ${index}
  ${value}=  izi find objectId element value  objectId=${feature_id}
  ...  wrapperElSelector=winner-criterias .winner-criterias__row
  ...  elThatHasObjectIdSelector=.winner-criterias__name
  ...  elThatHasValueSelector=.winner-criterias__name
  [Return]  ${value}

izi знайти на сторінці лоту ${index} поле description нецінового показника ${feature_id}
  izi обрати лот ${index}
  ${value}=  izi find objectId element value  objectId=${feature_id}
  ...  wrapperElSelector=winner-criterias .winner-criterias__row
  ...  elThatHasObjectIdSelector=.winner-criterias__name
  ...  elThatHasValueSelector=.winner-criterias__name-col info-popup span div span
  [Return]  ${value}

izi задати запитання на тендер
  [Arguments]  ${question}
  izi question-form open form
  izi question-form check tender
  izi question-form fill form  ${question}
  izi question-form submit form

izi задати запитання на лот
  [Arguments]  ${lotObjectId}  ${question}
  ${lotIndex}=  izi знайти index лоту за lotobjectid  ${lotObjectId}
  izi обрати лот ${lotIndex}
  izi question-form open form
  izi question-form check lot  ${lotObjectId}
  izi question-form fill form  ${question}
  izi question-form submit form

izi задати запитання на предмет
  [Arguments]  ${item_id}  ${question}
  izi question-form open form
  izi question-form check item  ${item_id}
  izi question-form fill form  ${question}
  izi question-form submit form

izi question-form open form
  Click Element  jquery=tender-tabs izi-tabs-2 .izi-tabs a:nth-child(3)
  Click Button  jquery=tender-tabs izi-tabs-2 questions .questions__ask-btn

izi question-form check lot
  [Arguments]  ${lotObjectId}
  ${status}=  Run Keyword And Return Status  Element Should Be Visible  jquery=questions question-create radio-group .checkbox:contains(Питання до лоту) label
  Run Keyword And Return If  '${status}' == 'False'  Fail
  Click Element  jquery=questions question-create radio-group .checkbox:contains(Питання до лоту) label
  Wait Until Element Is Visible  jquery=questions question-create lot-select
  izi dropdown select option that contains text  text=${lotObjectId}  dropDownSelector=questions question-create lot-select

izi question-form check item
  [Arguments]  ${item_id}
  ${status}=  Run Keyword And Return Status  Element Should Be Visible  jquery=questions question-create radio-group .checkbox:contains(Питання до предмету) label
  Run Keyword And Return If  '${status}' == 'False'  Fail
  Click Element  jquery=questions question-create radio-group .checkbox:contains(Питання до предмету) label
  Wait Until Element Is Visible  jquery=questions question-create item-select
  izi dropdown select option that contains text  text=${item_id}  dropDownSelector=questions question-create item-select

izi question-form fill form
  [Arguments]  ${question}
  Input Text  jquery=questions question-create .question-create__form label:first input  ${question.data.title}
  Input Text  jquery=questions question-create .question-create__form label textarea  ${question.data.description}

izi question-form check tender
  ${status}=  Run Keyword And Return Status  Element Should Be Visible  jquery=questions question-create radio-group .checkbox:contains(Питання до тендеру) label
  Return From Keyword If  '${status}' == 'False'
  Click Element  jquery=questions question-create radio-group .checkbox:contains(Питання до тендеру) label

izi question-form submit form
  Wait Until Element Is Visible  jquery=questions .question-create__btn-wrap button:not(button[disabled])
  Click Button  jquery=questions .question-create__btn-wrap button
  Wait Until Element Is Visible  jquery=questions .question-create .action-dialog-popup__btn-wrap button
  Click Button  jquery=questions .question-create .action-dialog-popup__btn-wrap button

izi знайти на сторінці тендеру запитання ${question_id} поле title
  Click Element  jquery=tender-tabs izi-tabs-2 .izi-tabs a:nth-child(3)
  ${value}=  izi find objectid element value  objectId=${question_id}
  ...  wrapperElSelector=questions .questions__item
  ...  elThatHasObjectIdSelector=.questions__subject
  ...  elThatHasValueSelector=.questions__subject
  [Return]  ${value}

izi знайти на сторінці тендеру запитання ${question_id} поле description
  Click Element  jquery=tender-tabs izi-tabs-2 .izi-tabs a:nth-child(3)
  ${value}=  izi find objectid element value  objectId=${question_id}
  ...  wrapperElSelector=questions .questions__item
  ...  elThatHasObjectIdSelector=.questions__subject
  ...  elThatHasValueSelector=.questions__content p:eq(1)
  [Return]  ${value}

izi знайти на сторінці тендеру запитання ${question_id} поле answer
  Click Element  jquery=tender-tabs izi-tabs-2 .izi-tabs a:nth-child(3)
  ${value}=  izi find objectid element value  objectId=${question_id}
  ...  wrapperElSelector=questions .questions__item
  ...  elThatHasObjectIdSelector=.questions__subject
  ...  elThatHasValueSelector=.questions__answer .questions__content p
  [Return]  ${value}

izi знайти index лоту за lotObjectId
  [Arguments]  ${lotObjectId}
  ${lotsCount}=  izi get page lots count
  ${lotIndex}=  set variable  ${EMPTY}
  :FOR  ${index}  IN RANGE  ${lotsCount}
  \  ${lotIndex}=  set variable  ${index}
  \  ${title}=  Run Keyword  izi знайти на сторінці лоту ${index} поле title
  \  Exit For Loop If  "${lotObjectId}" in "${title}"
  [Return]  ${lotIndex}

izi знайти на сторінці тендера поле title документу ${doc_id}
  ${value}=  izi find objectId element value  objectId=${doc_id}
  ...  wrapperElSelector=documents-versions .documents-versions__row
  ...  elThatHasObjectIdSelector=.documents-versions__name-val
  ...  elThatHasValueSelector=.documents-versions__name-val
  [Return]  ${value}

izi знайти на сторінці лоту ${index} поле title документу ${doc_id}
  izi обрати лот ${index}
  ${value}=  izi find objectId element value  objectId=${doc_id}
  ...  wrapperElSelector=documents-versions .documents-versions__row
  ...  elThatHasObjectIdSelector=.documents-versions__name-val
  ...  elThatHasValueSelector=.documents-versions__name-val
  [Return]  ${value}

izi знайти на сторінці тендера поле ulr документу ${doc_id}
  ${attribute}=  Set Variable  href
  ${value}=  Run Keyword  izi find objectId element attribute  attribute=${attribute}  objectId=${doc_id}
  ...  wrapperElSelector=documents-versions .documents-versions__row
  ...  elThatHasObjectIdSelector=.documents-versions__name-val
  ...  elThatHasValueSelector=.documents-versions__doc-download
  [Return]  ${value}

izi знайти на сторінці лоту ${index} поле ulr документу ${doc_id}
  izi обрати лот ${index}
  ${attribute}=  Set Variable  href
  ${value}=  Run Keyword  izi find objectId element attribute  attribute=${attribute}  objectId=${doc_id}
  ...  wrapperElSelector=documents-versions .documents-versions__row
  ...  elThatHasObjectIdSelector=.documents-versions__name-val
  ...  elThatHasValueSelector=.documents-versions__doc-download
  [Return]  ${value}

izi знайти поле title документу ${doc_id} вимоги ${complaintID}
  izi select claims tab
  izi open claim by id  ${complaintID}
  ${value}=  izi find objectId element value  objectId=${complaintID}
  ...  wrapperElSelector=pretense-row .pretense-row__content-block
  ...  elThatHasObjectIdSelector=.pretense-row__more-info .pretense-data__info p:has(strong:contains(Ідентифікатор вимоги),:contains(Ідентифікатор скарги)) span
  ...  elThatHasValueSelector=.pretense-row__more-info .pretense-phase__files .pretense-phase__list a
  [Return]  ${value}

izi знайти на сторінці тендера поле contracts[${index}].status
  Sleep  3
  ${value}=  Execute Javascript  return $("contract-info:eq(${index}) .contract-info__status").text().trim() || $("contract-info:eq(0) .contract-info__status").text().trim()
  ${value}=  convert_izi_string_to_prozorro_string  ${value}
  [Return]  ${value}

izi знайти на сторінці тендера поле contracts[${index}].value.amount
  Sleep  3
  ${value}=  Execute Javascript  return $("contract-info:eq(${index}) .contract-info__contract-value").text().trim() || $("contract-info:eq(0) .contract-info__contract-value").text().trim()
  ${value}=  izi convert izi number to prozorro number  ${value}
  [Return]  ${value}

izi знайти на сторінці тендера поле contracts[${index}].value.amountNet
  Sleep  3
  ${value}=  Execute Javascript  return $("contract-info:eq(${index}) .contract-info__contract-value-net").text().trim() || $("contract-info:eq(0) .contract-info__contract-value-net").text().trim()
  ${value}=  izi convert izi number to prozorro number  ${value}
  [Return]  ${value}

izi claim-submit-form open form
  [Arguments]  ${award_index}=${None}
  Run Keyword And Return If  '${award_index}'!='${None}'  izi award-claim-submit-form open form
  Click Element  jquery=tender-tabs izi-tabs-2 .izi-tabs a:nth-child(2)
  Click Button  jquery=claims tender-pretense-create .pretense-create__add-pretense-btn

izi award-claim-submit-form open form
  Click Element  jquery=tender-tabs izi-tabs-2 .izi-tabs a:nth-child(2)
  Click Button  jquery=claims award-pretense-create .pretense-create__add-pretense-btn

izi claim-submit-form fill data
  [Arguments]  ${claim}  ${award_index}=${None}
  Run Keyword And Return If  '${award_index}'!='${None}'  izi award-claim-submit-form fill data  ${claim}
  Input Text  jquery=claims .pretense-create__form .pretense-create__fieldset:first input  ${claim.data.title}
  Input Text  jquery=claims .pretense-create__form .pretense-create__fieldset:last textarea  ${claim.data.description}
  Sleep  2

izi award-claim-submit-form fill data
  [Arguments]  ${claim}
  Input Text  jquery=claims award-pretense-create .pretense-create__fieldset:first input  ${claim.data.title}
  Input Text  jquery=claims award-pretense-create .pretense-create__fieldset:last textarea  ${claim.data.description}
  Sleep  2

izi claim-submit-form add document
  [Arguments]  ${document_path}  ${award_index}=${None}
  Run Keyword And Return If  '${award_index}'!='${None}'  izi award-claim-submit-form add document  ${document_path}
  Choose File  jquery=claims tender-pretense-create .documents-manage:eq(0) .documents-manage__new-doc-btn input  ${document_path}
  Sleep  4

izi award-claim-submit-form add document
  [Arguments]  ${document_path}
  Choose File  jquery=claims award-pretense-create .documents-manage:eq(0) .documents-manage__new-doc-btn input  ${document_path}
  Sleep  4

izi claim-submit-form submit form
  [Arguments]  ${award_index}=${None}
  Run Keyword And Return If  '${award_index}'!='${None}'  izi award-claim-submit-form submit form
  Wait Until Element Is Visible  jquery=claims .pretense-create__btn-wrap button
  Sleep  2
  Click Button  jquery=claims .pretense-create__btn-wrap button
  Sleep  2
  Wait Until Element Is Visible  jquery=claims tender-pretense-create .action-dialog-popup.active .action-dialog-popup__btn-wrap__btn-ok  20 seconds
  Click Button  jquery=claims tender-pretense-create .action-dialog-popup.active .action-dialog-popup__btn-wrap__btn-ok
  Sleep  2

izi award-claim-submit-form submit form
  Wait Until Element Is Visible  jquery=claims award-pretense-create .pretense-create__btn-wrap button
  Sleep  2
  Click Element  jquery=claims award-pretense-create .pretense-create__btn-wrap button
  Sleep  2
  Wait Until Element Is Visible  jquery=claims award-pretense-create .action-dialog-popup.active .action-dialog-popup__btn-wrap__btn-ok  20 seconds
  Sleep  2
  Click Button  jquery=claims award-pretense-create .action-dialog-popup.active .action-dialog-popup__btn-wrap__btn-ok

izi claim-submit-form select lot radiobutton
  Click Element  jquery=claims .pretense-create__checker div:first .checkbox:last label
  Sleep  2

izi claim-submit-form save draft
  [Arguments]  ${award_index}=${None}
  Run Keyword And Return If  '${award_index}'!='${None}'  izi award-claim-submit-form save draft
  Wait Until Element Is Visible  jquery=claims .pretense-create__save
  Sleep  2
  Click Element  jquery=claims .pretense-create__save
  Sleep  2
  Wait Until Element Is Visible  jquery=claims tender-pretense-create .action-dialog-popup.active .action-dialog-popup__btn-wrap__btn-ok  20 seconds
  Sleep  2
  Click Button  jquery=claims tender-pretense-create .action-dialog-popup.active .action-dialog-popup__btn-wrap__btn-ok
  Wait Until Page Contains Element  jquery=claims tender-pretense-create[draftpretenseid]
  Sleep  2

izi award-claim-submit-form save draft
  Wait Until Element Is Visible  jquery=claims .pretense-create__save
  Sleep  2
  Click Element  jquery=claims .pretense-create__save
  Sleep  2
  Wait Until Element Is Visible  jquery=claims award-pretense-create .action-dialog-popup.active .action-dialog-popup__btn-wrap__btn-ok  20 seconds
  Sleep  2
  Click Button  jquery=claims award-pretense-create .action-dialog-popup.active .action-dialog-popup__btn-wrap__btn-ok
  Wait Until Page Contains Element  jquery=claims award-pretense-create[draftpretenseid]
  Sleep  2

izi select claims tab
  Execute Javascript  window.scroll(45,600)
  Click Element  jquery=tender-tabs izi-tabs-2 .izi-tabs a:nth-child(2)
  Sleep  2

izi open claim by id
  [Arguments]  ${complaintID}
  Click Element  jquery=claims pretense-row .pretense-row__content-block:has(span:contains(${complaintID})) .pretense-row__btn
  Sleep  2

izi cancel claim
  [Arguments]  ${complaintID}  ${cancellation_data}
  Click Element  jquery=.pretense-row__content-block:has(span:contains(${complaintID})) .btn_8:contains(Відкликати)
  Sleep  2
  Input Text  jquery=pretense-revoke textarea  ${cancellation_data.data.cancellationReason}
  Sleep  2
  Click Button  jquery=pretense-revoke .btn_2
  Sleep  2

izi створити вимогу про виправлення умов тендера
  [Arguments]  ${tender_uaid}  ${claim}  ${document_path}
  izi claim-submit-form open form
  izi claim-submit-form fill data  ${claim}
  izi claim-submit-form add document  ${document_path}
  izi claim-submit-form submit form
  ${complaintID}=  izi знайти ідентифікатор вимоги  ${tender_uaid}  ${claim.data.title}
  [Return]  ${complaintID}

izi cтворити вимогу про виправлення умов лоту
  [Arguments]  ${tender_uaid}  ${lot_id}  ${claim}  ${document_path}
  izi claim-submit-form open form
  izi claim-submit-form select lot radiobutton
  izi dropdown select option that contains text  text=${lot_id}  dropDownSelector=claims tender-pretense-create lot-select
  izi claim-submit-form fill data  ${claim}
  izi claim-submit-form add document  ${document_path}
  izi claim-submit-form submit form
  ${complaintID}=  izi знайти ідентифікатор вимоги  ${tender_uaid}  ${claim.data.title}
  [Return]  ${complaintID}

izi створити чернетку вимоги про виправлелння умов закупівлі
  [Arguments]  ${tender_uaid}  ${claim}
  izi claim-submit-form open form
  izi claim-submit-form fill data  ${claim}
  izi claim-submit-form save draft
  ${complaintID}=  Execute Javascript  return $('claims tender-pretense-create').attr('draftpretenseid')
  [Return]  ${complaintID}

izi створити чернетку вимоги про виправлення умов лоту
  [Arguments]  ${tender_uaid}  ${claim}  ${lot_id}
  izi claim-submit-form open form
  izi claim-submit-form select lot radiobutton
  izi dropdown select option that contains text  text=${lot_id}  dropDownSelector=tender-pretense-create lot-select
  izi claim-submit-form fill data  ${claim}
  izi claim-submit-form save draft
  ${complaintID}=  Execute Javascript  return $('claims tender-pretense-create').attr('draftpretenseid')
  [Return]  ${complaintID}

izi створити вимогу про виправлення визначення переможця
  [Arguments]  ${tender_uaid}  ${claim}  ${award_index}  ${document_path}
  ${awardId}=  izi get awardId by awardIndex
  ...  awardIndex=${award_index}
  izi claim-submit-form open form  ${award_index}
  izi dropdown select option  key=${awardId}  dropDownSelector=claims award-pretense-create award-select
  izi claim-submit-form fill data  ${claim}  ${award_index}
  izi claim-submit-form add document  ${document_path}  ${award_index}
  izi claim-submit-form submit form  ${award_index}
  ${complaintID}=  izi знайти ідентифікатор вимоги  ${tender_uaid}  ${claim.data.title}
  [Return]  ${complaintID}

izi підтвердити вирішення вимоги про виправлення визначення переможця
  [Arguments]  ${tender_uaid}  ${complaintID}  ${confirmation_data}  ${award_index}
  ${confirmation}=  Set Variable  ${confirmation_data.data.satisfied}
  izi select claims tab
  izi open claim by id  ${complaintID}
  Run Keyword If  '${confirmation}' == 'True'  Click Element  jquery=claims pretense-row .pretense-row__content-block:has(span:contains(${complaintID})) claim-satisfaction .btn_9
  ...  ELSE  Click Element  jquery=claims pretense-row .pretense-row__content-block:has(span:contains(${complaintID})) claim-satisfaction .btn_10

izi створити чернетку вимоги про виправлення визначення переможця
  [Arguments]  ${tender_uaid}  ${claim}  ${award_index}
  ${awardId}=  izi get awardId by awardIndex
  ...  awardIndex=${award_index}
  izi claim-submit-form open form  ${award_index}
  izi dropdown select option  key=${awardId}  dropDownSelector=claims award-pretense-create award-select
  izi claim-submit-form fill data  ${claim}  ${award_index}
  izi claim-submit-form save draft  ${award_index}
  ${complaintID}=  Execute Javascript  return $('claims award-pretense-create').attr('draftpretenseid')
  [Return]  ${complaintID}

izi знайти ідентифікатор вимоги
  [Arguments]  ${tender_uaid}  ${claim.data.title}
  izi перейти на сторінку тендеру  ${tender_uaid}
  ${complaintID}=  izi find objectId element value  objectId=${claim.data.title}
  ...  wrapperElSelector=claims pretense-row .pretense-row__content-block
  ...  elThatHasObjectIdSelector=.pretense-row__topic
  ...  elThatHasValueSelector=.pretense-row__more-info .pretense-data__info p:has(strong:contains(Ідентифікатор вимоги),:contains(Ідентифікатор скарги)) span
  [Return]  ${complaintID}

izi підтвердити\заперечити вирішення вимоги про виправлення умов закупівлі
  [Arguments]  ${complaintID}  ${confirmation_data}  ${tender_uaid}
  izi select claims tab
  izi open claim by id  ${complaintID}
  ${confirmation}=  Set Variable  ${confirmation_data.data.satisfied}
  Run Keyword If  '${confirmation}' == 'True'  Click Element  jquery=claims pretense-row .pretense-row__content-block:has(span:contains(${complaintID})) claim-satisfaction .btn_9
  ...  ELSE  Click Element  jquery=claims pretense-row .pretense-row__content-block:has(span:contains(${complaintID})) claim-satisfaction .btn_10
  izi sync tender  ${tender_uaid}

izi cкасувати вимогу до лоту або закупівлі
  [Arguments]  ${tender_uaid}  ${complaintID}  ${cancellation_data}  ${award_index}=${None}
  izi select claims tab
  ${isClaimDraft}=  Run Keyword And Return Status  izi cкасувати чернетку вимоги  ${cancellation_data}
  Return From Keyword If  '${isClaimDraft}' == 'True'
  izi open claim by id  ${complaintID}
  izi cancel claim  ${complaintID}  ${cancellation_data}

izi cкасувати чернетку вимоги
  [Arguments]  ${cancellation_data}
  Run Keyword  Execute Javascript  $('claims .pretense-create__draftRevokeReason').val("${cancellation_data.data.cancellationReason}")
  Sleep  2
  Click Element  jquery=claims .feed-block .feed-block__close:first
  Wait Until Element Is Visible  jquery=.action-dialog-popup[style=""] .action-dialog-popup__action-block:first .btn_12
  Click Button  jquery=.action-dialog-popup[style=""] .action-dialog-popup__action-block:first .btn_12

izi отримати поле status з вимоги
  [Arguments]  ${complaintID}
  izi select claims tab
  ${attribute}=  Set Variable  status

  ${isDraftComplaint}=  Execute Javascript  return $('claims tender-pretense-create').attr('draftpretenseid')=='${complaintID}'
  Run Keyword And Return If  '${isDraftComplaint}'=='True'  izi отримати поле status з чернетки вимоги

  ${value}=  izi find objectId element attribute  attribute=${attribute}  objectId=${complaintID}
  ...  wrapperElSelector=pretense-row .pretense-row__content-block
  ...  elThatHasObjectIdSelector=.pretense-row__more-info .pretense-data__info p:has(strong:contains(Ідентифікатор вимоги),:contains(Ідентифікатор скарги)) span
  ...  elThatHasValueSelector=.pretense-row__status

  [Return]  ${value}

izi отримати поле status з чернетки вимоги
  ${value}=  Execute Javascript  return $('claims tender-pretense-create').attr('status')
  [Return]  ${value}


izi отримати поле description з вимоги
  [Arguments]  ${complaintID}
  izi select claims tab
  ${value}=  izi find objectId element value  objectId=${complaintID}
  ...  wrapperElSelector=pretense-row .pretense-row__content-block
  ...  elThatHasObjectIdSelector=.pretense-row__more-info .pretense-data__info p:has(strong:contains(Ідентифікатор вимоги),:contains(Ідентифікатор скарги)) span
  ...  elThatHasValueSelector=.pretense-row__more-info .pretense-data__text p
  [Return]  ${value}

izi отримати поле title з вимоги
  [Arguments]  ${complaintID}
  izi select claims tab
  ${value}=  izi find objectId element value  objectId=${complaintID}
  ...  wrapperElSelector=pretense-row .pretense-row__content-block
  ...  elThatHasObjectIdSelector=.pretense-row__more-info .pretense-data__info p:has(strong:contains(Ідентифікатор вимоги),:contains(Ідентифікатор скарги)) span
  ...  elThatHasValueSelector=.pretense-row__topic
  [Return]  ${value}

izi отримати поле resolutionType з вимоги
  [Arguments]  ${complaintID}
  izi select claims tab
  ${attribute}=  Set Variable  resolutiontype
  ${value}=  izi find objectId element attribute  attribute=${attribute}  objectId=${complaintID}
  ...  wrapperElSelector=pretense-row .pretense-row__content-block
  ...  elThatHasObjectIdSelector=.pretense-row__more-info .pretense-data__info p:has(strong:contains(Ідентифікатор вимоги),:contains(Ідентифікатор скарги)) span
  ...  elThatHasValueSelector=.pretense-row__status
  [Return]  ${value}

izi отримати поле resolution з вимоги
  [Arguments]  ${complaintID}
  izi select claims tab
  ${value}=  izi find objectId element value  objectId=${complaintID}
  ...  wrapperElSelector=pretense-row .pretense-row__content-block
  ...  elThatHasObjectIdSelector=.pretense-row__more-info .pretense-data__info p:has(strong:contains(Ідентифікатор вимоги),:contains(Ідентифікатор скарги)) span
  ...  elThatHasValueSelector=.pretense-row__more-info .pretense-phase__note:first
  [Return]  ${value}

izi отримати поле satisfied з вимоги
  [Arguments]  ${complaintID}
  izi select claims tab
  ${attribute}=  Set Variable  satisfied
  ${value}=  izi find objectId element attribute  attribute=${attribute}  objectId=${complaintID}
  ...  wrapperElSelector=pretense-row .pretense-row__content-block
  ...  elThatHasObjectIdSelector=.pretense-row__more-info .pretense-data__info p:has(strong:contains(Ідентифікатор вимоги),:contains(Ідентифікатор скарги)) span
  ...  elThatHasValueSelector=.pretense-row__status
  ${value}=  convert_izi_string_to_prozorro_string  ${value}
  [Return]  ${value}

izi отримати поле cancellationReason з вимоги
  [Arguments]  ${complaintID}
  izi select claims tab
  ${value}=  izi find objectId element value  objectId=${complaintID}
  ...  wrapperElSelector=pretense-row .pretense-row__content-block
  ...  elThatHasObjectIdSelector=.pretense-row__more-info .pretense-data__info p:has(strong:contains(Ідентифікатор вимоги),:contains(Ідентифікатор скарги)) span
  ...  elThatHasValueSelector=.pretense-row__more-info .pretense-phase__files:has(.pretense-phase__topic:contains(Вимогу було відкликано),:contains(Скаргу було відкликано)) .pretense-phase__note
  [Return]  ${value}

izi знайти на сторінці тендера поле procurementMethodType
  ${value}=  Execute Javascript  return $('.tender-info-notes:not(.mobile) ul li strong:contains(Тип процедури:)+span').text().trim()
  ${value}=  izi_service.get_prozorro_pmtype_by_izi_pmtext  ${value}
  [Return]  ${value}

izi подати цінову пропозицію на тендер
  [Arguments]  ${bid}  ${lotIndex}=${None}
  ${type}=  izi знайти на сторінці тендера поле procurementMethodType
  Run Keyword And Return If  '${type}' == 'esco'  izi подати цінову пропозицію на esco тендер  ${bid}  ${lotIndex}
  Run Keyword If  '${lotIndex}' != '${None}'  izi обрати лот ${lotIndex}
  ${valueAmount}=  Run Keyword If  '${type}' != 'closeFrameworkAgreementSelectionUA'  Set Variable  ${bid.data.value.amount}
  ...  ELSE  izi fix frameworkSelection valueAmount  ${bid.data.value.amount}
  izi bid-submit-form open form
  Run Keyword If  '${type}' != 'competitiveDialogueUA' and '${type}' != 'competitiveDialogueEU'
  ...  izi bid-submit-form fill valueAmount  valueAmount=${valueAmount}
  izi bid-submit-form fill features  parameters=${bid.data.parameters}
  Run Keyword If  '${type}' != 'belowThreshold' and '${type}' != 'closeFrameworkAgreementSelectionUA'  Run Keywords
  ...  izi bid-submit-form check selfEligible
  ...  izi bid-submit-form check selfQualified
  Run Keyword If  '${type}' != 'closeFrameworkAgreementSelectionUA'
  ...  izi bid-submit-form add document  docType=3
  izi bid-submit-form submit form
  izi bid-submit-form close submit-form by clicking X

izi подати цінову пропозицію на esco тендер
  [Arguments]  ${bid}  ${lotIndex}=${None}
  Run Keyword If  '${lotIndex}' != '${None}'  izi обрати лот ${lotIndex}
  izi bid-submit-form open form
  Execute Javascript  $('esco-bid-submit .esco-value__contract-duration-years-select .izi-select__select li[key=${bid.data.value.contractDuration.years}]').click()
  Execute Javascript  $('esco-bid-submit .esco-value__contract-duration-days-input').val(${bid.data.value.contractDuration.days})[0].dispatchEvent(new Event('input'))
  Execute Javascript  $('esco-bid-submit .esco-value__yearly-payments-percentage-input').val((+'${bid.data.value.yearlyPaymentsPercentage}' * 100).toFixed(3))[0].dispatchEvent(new Event('input'))
  Sleep  1s
  ${periodsLength}=  Get Length  ${bid.data.value.annualCostsReduction}
  :FOR  ${index}  IN RANGE  0  ${periodsLength}
  \  ${periodExists}=  Execute Javascript  return !!$('esco-bid-submit .esco-value__acr-periods .esco-value__acr-periods-col:eq(1) .esco-value__acr-periods-cell:eq(' + (+'${index}' + 1) + ') input').length
  \  Continue For Loop If  '${periodExists}' == 'False'
  \  Execute Javascript  $('esco-bid-submit .esco-value__acr-periods .esco-value__acr-periods-col:eq(1) .esco-value__acr-periods-cell:eq(' + (+'${index}' + 1) + ') input').val(${bid.data.value.annualCostsReduction[${index}]})[0].dispatchEvent(new Event('input'))
  izi bid-submit-form fill features  parameters=${bid.data.parameters}
  izi bid-submit-form check selfEligible
  izi bid-submit-form check selfQualified
  izi bid-submit-form add document  docType=3
  Sleep  1s
  izi bid-submit-form submit form
  izi bid-submit-form close submit-form by clicking X

izi fix frameworkSelection valueAmount
  [Arguments]  ${valueAmount}
  ${valueAmount}=  convert to string  ${valueAmount}
  ${valueAmount}=  Set Variable  ${valueAmount[:4]}
  Run Keyword And Return  convert to number  ${valueAmount}

izi bid-submit-form open form
  Click Element  jquery=bid-status .bid-status__bid-form-btn
  Wait Until Page Contains Element  jquery=.bid-submit fullscreen-popup.fullscreen-popup__opened

izi bid-submit-form close submit-form by clicking X
  ${isOpened}=  Execute Javascript  return !!$('.bid-submit fullscreen-popup.fullscreen-popup__opened').length
  Return From Keyword If  '${isOpened}' == 'False'
  Click Element  jquery=.bid-submit > fullscreen-popup > .fullscreen-popup__wrap > .fullscreen-popup__content > .popup__close
  Run Keyword And Ignore Error  Click Button  jquery=.bid-submit-1 .fullscreen-popup__opened .fullscreen-popup__content > .action-dialog-popup .btn_12
  Wait Until Element Is Not Visible  jquery=.bid-submit fullscreen-popup

izi bid-submit-form fill valueAmount
  [Arguments]  ${valueAmount}
  Input Text  jquery=.bid-submit .value-submit input  '${valueAmount}'

izi bid-submit-form fill features
  [Arguments]  ${parameters}
  ${parametersLength}=  Get Length  ${parameters}
  :FOR  ${index}  IN RANGE  0  ${parametersLength}
  \  ${code}=  Get From Dictionary  ${parameters[${index}]}  code
  \  ${value}=  Get From Dictionary  ${parameters[${index}]}  value
  \  ${featureExists}=  Execute Javascript  return !!$('.bid-submit .bid-submit__features label[code="${code}"]').length
  \  Continue For Loop If  '${featureExists}' == 'False'
  \  Run Keyword  izi dropdown select option  dropDownSelector=.bid-submit .bid-submit__features label[code="${code}"] feature-values-select  key=${value}

izi bid-submit-form check selfEligible
  izi checkbox check change  checkboxSelector=.bid-submit self-options checkbox:eq(0)  check=True

izi bid-submit-form check selfQualified
  izi checkbox check change  checkboxSelector=.bid-submit self-options checkbox:eq(1)  check=True

izi bid-submit-form add document
  [Arguments]  ${docType}  ${filePath}=${None}  ${language}=3  ${confidentialityText}=${None}  ${isDescriptionDecision}=${None}
  ${documentManageSelector}=  Set Variable  .bid-submit documents-manage
  ${filePath}  ${fileName}  ${fileContent}  Run Keyword If  '${filePath}' == '${None}'  create_fake_doc
  ...  ELSE  Set Variable  ${filePath}  ${None}  ${None}
  Run Keyword And Return  izi document-manage add document
  ...  documentManageSelector=${documentManageSelector}
  ...  filePath=${filePath}
  ...  docType=${docType}
  ...  language=${language}
  ...  confidentialityText=${confidentialityText}
  ...  isDescriptionDecision=${isDescriptionDecision}


izi bid-submit-form add document new version
  [Arguments]  ${docObjectId}  ${docType}  ${filePath}=${None}  ${language}=3  ${confidentialityText}=${None}  ${isDescriptionDecision}=${None}
  ${documentManageSelector}=  Set Variable  .bid-submit documents-manage
  ${filePath}  ${fileName}  ${fileContent}  Run Keyword If  '${filePath}' == '${None}'  create_fake_doc
  ...  ELSE  Set Variable  ${filePath}  ${None}  ${None}
  ${docId}=  Run Keyword  izi find objectId element attribute
  ...  attribute=docId
  ...  objectId=${docObjectId}
  ...  wrapperElSelector=${documentManageSelector} documents-view .documents-view__row
  ...  elThatHasObjectIdSelector=.documents-view__name
  ...  elThatHasValueSelector=.documents-view__name-col

  ${docId}=  Get Variable Value  ${IZI_TMP_DICT['${docObjectId}']}  ${docId}
  Run Keyword And Return If  '${docId}' == '${None}'  Fail
  Set To Dictionary  ${IZI_TMP_DICT}  ${docObjectId}=${docId}
  Run Keyword And Return  izi document-manage add document new version
  ...  documentManageSelector=${documentManageSelector}
  ...  filePath=${filePath}
  ...  docType=${docType}
  ...  language=${language}
  ...  confidentialityText=${confidentialityText}
  ...  isDescriptionDecision=${isDescriptionDecision}
  ...  docId=${docId}

izi bid-submit-form change document
  [Arguments]  ${docObjectId}  ${docType}  ${language}  ${confidentialityText}  ${isDescriptionDecision}
  ${documentManageSelector}=  Set Variable  .bid-submit documents-manage
  ${docId}=  Run Keyword  izi find objectId element attribute
  ...  attribute=docId
  ...  objectId=${docObjectId}
  ...  wrapperElSelector=${documentManageSelector} documents-view .documents-view__row
  ...  elThatHasObjectIdSelector=.documents-view__name
  ...  elThatHasValueSelector=.documents-view__name-col
  ${docId}=  Get Variable Value  ${IZI_TMP_DICT['${docObjectId}']}  ${docId}
  Run Keyword And Return If  '${docId}' == '${None}'  Fail
  Set To Dictionary  ${IZI_TMP_DICT}  ${docObjectId}=${docId}
  ${title}=  izi document-manage get document title  docId=${docId}  documentManageSelector=${documentManageSelector}
  ${filePath}  ${fileName}  ${fileContent}  create_fake_doc
  Run Keyword And Return  izi document-manage add document new version
  ...  documentManageSelector=${documentManageSelector}
  ...  filePath=${filePath}
  ...  docType=${docType}
  ...  language=${language}
  ...  confidentialityText=${confidentialityText}
  ...  isDescriptionDecision=${isDescriptionDecision}
  ...  docId=${docId}

izi document-manage get document url
  [Arguments]  ${docId}  ${documentManageSelector}
  ${url}=  Execute Javascript  return $('${documentManageSelector} documents-view .documents-view__row .documents-view__name-col[docid=${docId}] .documents-view__name').attr('href')
  [Return]  ${url}

izi document-manage get document title
  [Arguments]  ${docId}  ${documentManageSelector}
  ${title}=  Get Text  jquery=${documentManageSelector} documents-view .documents-view__row .documents-view__name-col[docid=${docId}] .documents-view__name
  [Return]  ${title}

izi document-manage add document new version
  [Arguments]  ${docId}  ${documentManageSelector}  ${filePath}  ${docType}  ${language}  ${confidentialityText}=${None}  ${isDescriptionDecision}=${None}
  ${canAddDocument}=  Execute Javascript  return !!$('${documentManageSelector} documents-view .documents-view__row .documents-view__name-col[docid=${docId}]~.documents-view__controls-col .documents-view__new-ver').length
  Run Keyword And Return If  '${canAddDocument}' == 'False'  Fail
  Choose File  jquery=${documentManageSelector} documents-view .documents-view__row .documents-view__name-col[docid=${docId}]~.documents-view__controls-col .documents-view__new-ver input  ${filePath}
  ${docCreateNewVersionSelector}=  Set Variable  ${documentManageSelector} document-new-version
  Wait Until Page Contains Element  jquery=${docCreateNewVersionSelector}
  Run Keyword If  "${confidentialityText}" != "${None}"
  ...  Run Keywords
  ...  izi checkbox check change  checkboxSelector=${docCreateNewVersionSelector} .document-manage__checkbox:eq(1) checkbox  check=True
  ...  AND
  ...  Input Text  jquery=${docCreateNewVersionSelector} .document-new-version__confidentiality input  ${confidentialityText}
  Run Keyword If  "${isDescriptionDecision}" != "${None}"
  ...  izi checkbox check change  checkboxSelector=${docCreateNewVersionSelector} .document-manage__checkbox:eq(0) checkbox  check=True
  Run Keyword If  '${language}' != 'None'  izi dropdown select option  dropDownSelector=${docCreateNewVersionSelector} language-select  key=${language}
  Run Keyword If  '${docType}' != 'None'  izi dropdown select option  dropDownSelector=${docCreateNewVersionSelector} document-type-select  key=${docType}
  ${docVersionsCount}=  Execute Javascript  return $('${documentManageSelector} documents-view .documents-view__row .documents-view__name-col[docid=${docId}]~.documents-view__versions-col document-versions-urls a').length
  Click Element  jquery=${docCreateNewVersionSelector} .document-manage__btn-wrap button
  Wait Until Page Contains Element  jquery=${documentManageSelector} documents-view .documents-view__row .documents-view__name-col[docid=${docId}]~.documents-view__versions-col document-versions-urls a:eq(${docVersionsCount})


izi document-manage add document
  [Arguments]  ${documentManageSelector}  ${filePath}  ${docType}  ${language}=3  ${confidentialityText}=${None}  ${isDescriptionDecision}=${None}
  ${canAddDocument}=  Execute Javascript  return !!$('${documentManageSelector} .documents-manage__new-doc-btn').length
  Run Keyword And Return If  '${canAddDocument}' == 'False'  Fail
  Choose File  jquery=${documentManageSelector} .documents-manage__new-doc-btn input  ${filePath}
  ${docCreateFormSelector}=  Set Variable  ${documentManageSelector} document-create-list .document-create-list__item:eq(0) document-create
  Wait Until Page Contains Element  jquery=${docCreateFormSelector}
  Run Keyword If  "${confidentialityText}" != "${None}"
  ...  Run Keywords
  ...  izi checkbox check change  checkboxSelector=${docCreateFormSelector} .document-manage__checkbox:eq(1) checkbox  check=True
  ...  AND
  ...  Input Text  jquery=${docCreateFormSelector} .document-create__confidentiality  ${confidentialityText}
  Run Keyword If  "${isDescriptionDecision}" != "${None}"
  ...  izi checkbox check change  checkboxSelector=${docCreateFormSelector} .document-manage__checkbox:eq(0) checkbox  check=True
  izi dropdown select option  dropDownSelector=${docCreateFormSelector} language-select  key=${language}
  izi dropdown select option  dropDownSelector=${docCreateFormSelector} document-type-select  key=${docType}
  ${currDocsLength}=  Execute Javascript  return $('${documentManageSelector} documents-view .documents-view__row').length
  Click Element  jquery=${documentManageSelector} document-create-list .document-manage__btn-wrap button
  Wait Until Page Contains Element  jquery=${documentManageSelector} documents-view .documents-view__row:eq(${currDocsLength})

izi bid-submit-form submit form
  capture page screenshot
  ${canSubmit}=  Execute Javascript  return !!$('.bid-submit .bid-submit__control button:not(button[disabled])').length
  Run Keyword And Return If  '${canSubmit}' == 'False'  Fail
  Click Element  jquery=.bid-submit .bid-submit__bid-submit-btn
  ${dialogSelector}=  Set Variable  bid-submit-1 > fullscreen-popup > .fullscreen-popup__wrap > .fullscreen-popup__content > action-dialog-popup.active
  Wait Until Element Is Visible  jquery=${dialogSelector}  20
  ${dialogOkBtnSelector}=  Set Variable  ${dialogSelector} .action-dialog-popup__btn-wrap__btn-ok
  Click Element  jquery=${dialogOkBtnSelector}

izi bid-submit-form cancel bid
  ${canCancel}=  Execute Javascript  return !!$('.bid-submit .bid-submit__control button:eq(1):not(button[disabled])').length
  Run Keyword And Return If  '${canCancel}' == 'False'  Fail
  Click Element  jquery=.bid-submit .bid-submit__bid-revoke-btn
  ${dialogSelector}=  Set Variable  bid-submit-1 > fullscreen-popup > .fullscreen-popup__wrap > .fullscreen-popup__content > action-dialog-popup.active
  ${messageDialogSelector}=  Set Variable  ${dialogSelector} .action-dialog-popup__message
  Wait Until Element Is Visible  jquery=${messageDialogSelector}:contains(Підтвердіть відкликання пропозиці)  20
  ${dialogOkBtnSelector}=  Set Variable  ${dialogSelector} .action-dialog-popup__btn-wrap__btn-ok
  Click Element  jquery=${dialogOkBtnSelector}
  Wait Until Element Is Visible  jquery=${messageDialogSelector}:contains(Пропозиція відкликана)  20
  Click Element  jquery=${dialogOkBtnSelector}

izi bid-submit-form get valueAmount
  ${value}=  Get Value  jquery=.bid-submit .value-submit input
  ${value}=  Convert To Number  ${value}
  [Return]  ${value}

izi скасувати цінову пропозицію на тендер
  izi bid-submit-form open form
  izi bid-submit-form cancel bid
  izi bid-submit-form close submit-form by clicking X

izi скасувати цінову пропозицію на лот
  [Arguments]  ${lotIndex}
  izi обрати лот ${lotIndex}
  Run Keyword And Return  izi скасувати цінову пропозицію на тендер

izi знайти на сторінці тендера поле пропозиції lotValues[${index}].${field}
  Run Keyword And Return  izi знайти на сторінці лоту ${index} поле пропозиції ${field}

izi знайти на сторінці лоту ${index} поле пропозиції value.amount
  izi обрати лот ${index}
  Run Keyword And Return  izi знайти на сторінці тендера поле пропозиції value.amount

izi знайти на сторінці тендера поле пропозиції value.amount
  izi bid-submit-form open form
  ${value}=  Run Keyword  izi bid-submit-form get valueAmount
  izi bid-submit-form close submit-form by clicking X
  [Return]  ${value}

izi знайти на сторінці тендера поле qualificationPeriod.endDate
  ${value}=  Get Text  jquery=tender-lot-status .tender-lot-status__complain-period span
  ${value}=  izi convert izi date to prozorro date  ${value}
  [Return]  ${value}

izi змінити на сторінці тендера поле пропозиції lotValues[${index}].${field} на ${fieldvalue}
  Run Keyword And Return  izi змінити на сторінці лоту ${index} поле пропозиції ${field} на ${fieldvalue}

izi змінити на сторінці лоту ${index} поле пропозиції value.amount на ${valueAmount}
  izi обрати лот ${index}
  Run Keyword And Return  izi змінити на сторінці тендера поле пропозиції value.amount на ${valueAmount}

izi змінити на сторінці тендера поле пропозиції value.amount на ${valueAmount}
  izi bid-submit-form open form
  izi bid-submit-form fill valueAmount  ${valueAmount}
  izi bid-submit-form submit form
  izi bid-submit-form close submit-form by clicking X

izi знайти на сторінці тендера поле пропозиції status
  ${value}=  Execute Javascript  return $('bid-status[przBidStatus]').attr('przBidStatus')
  [Return]  ${value}

izi змінити на сторінці тендера поле пропозиції status на None
  izi bid-submit-form open form
  izi bid-submit-form submit form
  izi bid-submit-form close submit-form by clicking X

izi змінити на сторінці тендера поле пропозиції status на pending
  izi bid-submit-form open form
  izi bid-submit-form submit form
  izi bid-submit-form close submit-form by clicking X

izi змінити на сторінці тендера поле пропозиції status на active
  izi bid-submit-form open form
  izi bid-submit-form submit form
  izi bid-submit-form close submit-form by clicking X

izi дозавантажити документ до пропозиції лота
  [Arguments]  ${lotIndex}  ${filePath}  ${docType}
  izi обрати лот ${lotIndex}
  Run Keyword And Return  izi дозавантажити документ до пропозиції тендера  filePath=${filePath}  docType=${docType}

izi дозавантажити документ до пропозиції тендера
  [Arguments]  ${filePath}  ${docType}
  izi bid-submit-form open form
  izi bid-submit-form add document  docType=${docType}  filePath=${filePath}
  izi bid-submit-form submit form
  izi bid-submit-form close submit-form by clicking X

izi замінити документ в пропозиції лота
  [Arguments]  ${docObjectId}  ${lotIndex}  ${filePath}  ${docType}
  izi обрати лот ${lotIndex}
  Run Keyword And Return  izi замінити документ в пропозиції тендера  docObjectId=${docObjectId}  filePath=${filePath}  docType=${docType}

izi замінити документ в пропозиції тендера
  [Arguments]  ${docObjectId}  ${filePath}  ${docType}
  izi bid-submit-form open form
  izi bid-submit-form add document new version  docObjectId=${docObjectId}  filePath=${filePath}  docType=${docType}
  izi bid-submit-form submit form
  izi bid-submit-form close submit-form by clicking X

izi змінити документ в пропозиції лота
  [Arguments]  ${docObjectId}  ${lotIndex}  ${docData}
  izi обрати лот ${lotIndex}
  Run Keyword And Return  izi змінити документ в пропозиції тендера  docObjectId=${docObjectId}  docData=${docData}

izi змінити документ в пропозиції тендера
  [Arguments]  ${docObjectId}  ${docData}
  izi bid-submit-form open form
  Log  ${docData}  DEBUG
  ${confidentialityText}=  Get Variable Value  ${docData.data.confidentialityRationale}  ${None}
  ${docType}=  Set Variable  ${None}
  ${isDescriptionDecision}=  Set Variable  ${None}
  ${language}=  Set Variable  ${None}
  izi bid-submit-form change document
  ...  docObjectId=${docObjectId}
  ...  confidentialityText=${confidentialityText}
  ...  docType=${docType}
  ...  isDescriptionDecision=${isDescriptionDecision}
  ...  language=${language}
  izi bid-submit-form submit form
  izi bid-submit-form close submit-form by clicking X

izi знайти на сторінці лоту ${lotIndex} посилання на аукціон
  izi обрати лот ${lotIndex}
  Capture Page Screenshot
  Run Keyword And Return  izi знайти на сторінці тендера посилання на аукціон

izi знайти на сторінці тендера посилання на аукціон
  ${url}=  Execute Javascript  return $('tender-lot-status p strong:contains(Аукціон:)~a').attr('href')
  [Return]  ${url}

izi get document title from documents versions
  [Arguments]  ${documentsVersionsSelector}  ${docId}
  ${value}=  Execute Javascript  return $('${documentsVersionsSelector} .documents-versions__row[docId="${docId}"] .documents-versions__name-val').text().trim()
  [Return]  ${value}

izi знайти на сторінці тендера поле documents[${index}].title
  ${isTenderTabsExists}=  Execute Javascript  return !!$('tender-tabs').length
  Run Keyword If  '${isTenderTabsExists}' == 'True'  Click ELement  jquery=tender-tabs izi-tabs a[key="1"]
  Sleep  50ms
  ${docId}=  izi get tender docId by docIndex
  ...  docIndex=${index}
  ${docTitle}=  izi get document title from documents versions
  ...  documentsVersionsSelector=tender-documents documents-versions
  ...  docId=${docId}
  [Return]  ${docTitle}

izi bidding-results-form open award attachments popup
  [Arguments]  ${awardId}
  Click Element  jquery=bidding-results > .bidding-results__table > .bidding-results__row[awardId=${awardId}] > .bidding-results__attachment-col > a
  Sleep  500ms

izi bidding-results-form close award attachments popup
  Click Element  jquery=bidding-results attachments-popup .fullscreen-popup__opened .popup__close
  Sleep  500ms


izi знайти на сторінці тендера поле awards[${awardIndex}].documents[${docIndex}].title
  ${awardId}=  izi get awardId by awardIndex
  ...  awardIndex=${awardIndex}
  ${docId}=  izi get award docId by docIndex
  ...  awardIndex=${awardIndex}  docIndex=${docIndex}
  izi bidding-results-form open award attachments popup  awardId=${awardId}
  ${docTitle}=  izi get document title from documents versions
  ...  documentsVersionsSelector=bidding-results attachments-popup .fullscreen-popup__opened documents-versions
  ...  docId=${docId}
  izi bidding-results-form close award attachments popup
  [Return]  ${docTitle}


izi знайти на сторінці тендера поле awards[${awardIndex}].status
  ${awardId}=  izi get awardId by awardIndex
  ...  awardIndex=${awardIndex}
  ${value}=  Execute Javascript  return $('bidding-results > .bidding-results__table > .bidding-results__row[awardId=${awardId}] > .bidding-results__status-col .bidding-results__status').text().trim()
  ${value}=  izi_service.convert_izi_string_to_prozorro_string  ${value}
  [Return]  ${value}

izi знайти на сторінці тендера поле awards[${awardIndex}].suppliers[${supplierIndex}].address.countryName
  ${awardId}=  izi get awardId by awardIndex
  ...  awardIndex=${awardIndex}
  ${value}=  izi get countryName from iziAddressField
  ...  iziAddressFieldSelector=bidding-results > .bidding-results__table > .bidding-results__row[awardId=${awardId}] > .bidding-results__participant-col .info-popup .info-popup__popup__tip strong:contains(Адреса постачальника)+span
  [Return]  ${value}

izi знайти на сторінці тендера поле awards[${awardIndex}].suppliers[${supplierIndex}].address.locality
  ${awardId}=  izi get awardId by awardIndex
  ...  awardIndex=${awardIndex}
  ${value}=  izi get locality from iziAddressField
  ...  iziAddressFieldSelector=bidding-results > .bidding-results__table > .bidding-results__row[awardId=${awardId}] > .bidding-results__participant-col .info-popup .info-popup__popup__tip strong:contains(Адреса постачальника)+span
  [Return]  ${value}

izi знайти на сторінці тендера поле awards[${awardIndex}].suppliers[${supplierIndex}].address.postalCode
  ${awardId}=  izi get awardId by awardIndex
  ...  awardIndex=${awardIndex}
  ${value}=  izi get postalCode from iziAddressField
  ...  iziAddressFieldSelector=bidding-results > .bidding-results__table > .bidding-results__row[awardId=${awardId}] > .bidding-results__participant-col .info-popup .info-popup__popup__tip strong:contains(Адреса постачальника)+span
  [Return]  ${value}

izi знайти на сторінці тендера поле awards[${awardIndex}].suppliers[${supplierIndex}].address.region
  ${awardId}=  izi get awardId by awardIndex
  ...  awardIndex=${awardIndex}
  ${value}=  izi get region from iziAddressField
  ...  iziAddressFieldSelector=bidding-results > .bidding-results__table > .bidding-results__row[awardId=${awardId}] > .bidding-results__participant-col .info-popup .info-popup__popup__tip strong:contains(Адреса постачальника)+span
  [Return]  ${value}

izi знайти на сторінці тендера поле awards[${awardIndex}].suppliers[${supplierIndex}].address.streetAddress
  ${awardId}=  izi get awardId by awardIndex
  ...  awardIndex=${awardIndex}
  ${value}=  izi get streetAddress from iziAddressField
  ...  iziAddressFieldSelector=bidding-results > .bidding-results__table > .bidding-results__row[awardId=${awardId}] > .bidding-results__participant-col .info-popup .info-popup__popup__tip strong:contains(Адреса постачальника)+span
  [Return]  ${value}

izi get streetAddress from iziAddressField
  [Arguments]  ${iziAddressFieldSelector}
  ${value}=  Execute Javascript  return $("${iziAddressFieldSelector}").text()
  ${value}=  izi get streetAddress from iziAddressString
  ...  addressString=${value}
  [Return]  ${value}

izi get streetAddress from iziAddressString
  [Arguments]  ${addressString}
  ${value}=  Execute Javascript  return "${addressString}".split(', ').slice(4).join(', ')
  [Return]  ${value}

izi get region from iziAddressField
  [Arguments]  ${iziAddressFieldSelector}
  ${value}=  Execute Javascript  return $("${iziAddressFieldSelector}").text()
  ${value}=  izi get region from iziAddressString
  ...  addressString=${value}
  [Return]  ${value}

izi get region from iziAddressString
  [Arguments]  ${addressString}
  ${value}=  Execute Javascript  return "${addressString}".split(', ')[2]
  [Return]  ${value}

izi get postalCode from iziAddressField
  [Arguments]  ${iziAddressFieldSelector}
  ${value}=  Execute Javascript  return $("${iziAddressFieldSelector}").text()
  ${value}=  izi get postalCode from iziAddressString
  ...  addressString=${value}
  [Return]  ${value}

izi get postalCode from iziAddressString
  [Arguments]  ${addressString}
  ${value}=  Execute Javascript  return "${addressString}".split(', ')[0]
  [Return]  ${value}

izi get locality from iziAddressField
  [Arguments]  ${iziAddressFieldSelector}
  ${value}=  Execute Javascript  return $("${iziAddressFieldSelector}").text()
  ${value}=  izi get locality from iziAddressString
  ...  addressString=${value}
  [Return]  ${value}

izi get locality from iziAddressString
  [Arguments]  ${addressString}
  ${value}=  Execute Javascript  return "${addressString}".split(', ')[3].trim()
  [Return]  ${value}

izi get countryName from iziAddressField
  [Arguments]  ${iziAddressFieldSelector}
  ${value}=  Execute Javascript  return $("${iziAddressFieldSelector}").text()
  ${value}=  izi get countryName from iziAddressString
  ...  addressString=${value}
  [Return]  ${value}

izi get countryName from iziAddressString
  [Arguments]  ${addressString}
  ${value}=  Execute Javascript  return "${addressString}".split(', ')[1].match(/(^[^\\(]*)\\(?.*/)[1].trim()
  [Return]  ${value}

izi get countryName_ru from iziAddressField
  [Arguments]  ${iziAddressFieldSelector}
  ${value}=  Execute Javascript  return $("${iziAddressFieldSelector}").text()
  ${value}=  izi get countryName_ru from iziAddressString
  ...  addressString=${value}
  [Return]  ${value}

izi get countryName_ru from iziAddressString
  [Arguments]  ${addressString}
  ${value}=  Execute Javascript  return (("${addressString}".split(', ')[1].trim().split(' ')[1] || "").replace(/\\(|\\)/g, '').match(/[^\\,]*(?=²)/) || [])[0]
  [Return]  ${value}

izi get countryName_en from iziAddressField
  [Arguments]  ${iziAddressFieldSelector}
  ${value}=  Execute Javascript  return $("${iziAddressFieldSelector}").text()
  ${value}=  izi get countryName_en from iziAddressString
  ...  addressString=${value}
  [Return]  ${value}

izi get countryName_en from iziAddressString
  [Arguments]  ${addressString}
  ${value}=  Execute Javascript  return (("${addressString}".split(', ')[1].trim().split(' ')[1] || "").replace(/\\(|\\)/g, '').match(/[^\\,]*(?=³)/) || [])[0]
  [Return]  ${value}

izi знайти на сторінці тендера поле awards[${awardIndex}].suppliers[${supplierIndex}].contactPoint.telephone
  ${awardId}=  izi get awardId by awardIndex
  ...  awardIndex=${awardIndex}
  ${value}=  Execute Javascript  return $('bidding-results > .bidding-results__table > .bidding-results__row[awardId=${awardId}] > .bidding-results__participant-col .info-popup .info-popup__popup__tip strong:contains(Телефон)+span').text()
  [Return]  ${value}

izi знайти на сторінці тендера поле awards[${awardIndex}].suppliers[${supplierIndex}].contactPoint.name
  ${awardId}=  izi get awardId by awardIndex
  ...  awardIndex=${awardIndex}
  ${value}=  Execute Javascript  return $('bidding-results > .bidding-results__table > .bidding-results__row[awardId=${awardId}] > .bidding-results__participant-col .info-popup .info-popup__popup__tip strong:contains(Представник)+span').text()
  [Return]  ${value}

izi знайти на сторінці тендера поле awards[${awardIndex}].suppliers[${supplierIndex}].contactPoint.email
  ${awardId}=  izi get awardId by awardIndex
  ...  awardIndex=${awardIndex}
  ${value}=  Execute Javascript  return $('bidding-results > .bidding-results__table > .bidding-results__row[awardId=${awardId}] > .bidding-results__participant-col .info-popup .info-popup__popup__tip strong:contains(E-mail)+span').text()
  [Return]  ${value}

izi знайти на сторінці тендера поле awards[${awardIndex}].suppliers[${supplierIndex}].identifier.id
  ${awardId}=  izi get awardId by awardIndex
  ...  awardIndex=${awardIndex}
  ${value}=  Execute Javascript  return $('bidding-results > .bidding-results__table > .bidding-results__row[awardId=${awardId}] > .bidding-results__participant-col .info-popup .info-popup__popup__tip strong:contains(Код ЄДРПОУ)+span').text()
  [Return]  ${value}

izi знайти на сторінці тендера поле awards[${awardIndex}].suppliers[${supplierIndex}].name
  ${awardId}=  izi get awardId by awardIndex
  ...  awardIndex=${awardIndex}
  ${value}=  Execute Javascript  return $('bidding-results > .bidding-results__table > .bidding-results__row[awardId=${awardId}] > .bidding-results__participant-col .info-popup .info-popup__popup__tip strong:contains(Постачальник)+span').text()
  [Return]  ${value}

izi знайти на сторінці тендера поле awards[${awardIndex}].suppliers[${supplierIndex}].identifier.scheme
  ${awardId}=  izi get awardId by awardIndex
  ...  awardIndex=${awardIndex}
  ${value}=  Execute Javascript  return $('bidding-results > .bidding-results__table > .bidding-results__row[awardId=${awardId}] > .bidding-results__participant-col .info-popup .info-popup__popup__tip strong:contains(Схема Ідентифікації)+span').text()
  [Return]  ${value}

izi знайти на сторінці тендера поле awards[${awardIndex}].suppliers[${supplierIndex}].identifier.legalName
  ${awardId}=  izi get awardId by awardIndex
  ...  awardIndex=${awardIndex}
  ${value}=  Execute Javascript  return $('bidding-results > .bidding-results__table > .bidding-results__row[awardId=${awardId}] > .bidding-results__participant-col .info-popup .info-popup__popup__tip strong:contains(Постачальник)+span').text()
  [Return]  ${value}

izi знайти на сторінці тендера поле awards[${awardIndex}].value.amount
  ${awardId}=  izi get awardId by awardIndex
  ...  awardIndex=${awardIndex}
  ${textField}=  Execute Javascript  return $('bidding-results > .bidding-results__table > .bidding-results__row[awardId=${awardId}] > .bidding-results__value-col .bidding-results__value').text().trim()
  ${value}=  izi convert izi number to prozorro number  ${textField}

  [Return]  ${value}

izi знайти на сторінці тендера поле awards[${awardIndex}].value.currency
  ${awardId}=  izi get awardId by awardIndex
  ...  awardIndex=${awardIndex}
  ${iziCurr}=  Execute Javascript  return $('bidding-results > .bidding-results__table > .bidding-results__row[awardId=${awardId}]  > .bidding-results__value-col .bidding-results__value-curr').text().trim()
  ${curr}=  izi_service.get_prozorro_curr_by_izi_curr  ${iziCurr}
  Return From Keyword If  '${curr}' != '${None}'  ${curr}
  ${iziCurr}=  Execute Javascript  return ($('bidding-results > .bidding-results__table .bidding-results__table-head > .bidding-results__value-col').text().trim()).split(' ')[2].trim()
  ${curr}=  izi_service.get_prozorro_curr_by_izi_curr  ${iziCurr}
  [Return]  ${curr}

izi знайти на сторінці тендера поле awards[${awardIndex}].value.valueAddedTaxIncluded
  ${awardId}=  izi get awardId by awardIndex
  ...  awardIndex=${awardIndex}
  ${isTaxIncluded}=  Execute Javascript  return $('bidding-results > .bidding-results__table > .bidding-results__row[awardId=${awardId}] > .bidding-results__value-col .bidding-results__value-vat:contains(без ПДВ)').length ? false : $('bidding-results > .bidding-results__table > .bidding-results__row[awardId=${awardId}] > .bidding-results__value-col .bidding-results__value-vat:contains(з ПДВ)').length ? true : null
  Return From Keyword If  '${isTaxIncluded}' != '${None}'  ${isTaxIncluded}
  ${isTaxIncluded}=  Execute Javascript  return !$('bidding-results .bidding-results__table .bidding-results__table-head > .bidding-results__value-col:contains(без ПДВ)').length
  [Return]  ${isTaxIncluded}

izi get feature relatedOf
  [Arguments]  ${featureObjectId}
  ${value}=  izi find objectId element value
  ...  objectId=${featureObjectId}
  ...  wrapperElSelector=winner-criterias .winner-criterias__row
  ...  elThatHasObjectIdSelector=.winner-criterias__name
  ...  elThatHasValueSelector=.winner-criterias__name-col info-popup .info-popup__popup p span div span~strong
  Return From Keyword If  '${value}' == 'неціновий показник до закупівлі'  tenderer
  Return From Keyword If  '${value}' == 'неціновий показник до лоту'  lot
  Return From Keyword If  '${value}' == 'неціновий показник до предмету лоту'  item
  Return From Keyword If  '${value}' == 'неціновий показник до предмету закупівлі'  item

izi знайти на сторінці лоту ${lotIndex} поле featureOf нецінового показника ${featureObjectId}
  izi обрати лот ${lotIndex}
  Run Keyword And Return  izi get feature relatedOf  ${featureObjectId}

izi знайти на сторінці тендера поле featureOf нецінового показника ${featureObjectId}
  Run Keyword And Return  izi get feature relatedOf  ${featureObjectId}

izi знайти на сторінці тендера поле funders[${index}].name
  ${value}=  Execute Javascript  return $('funders-info .funders-info__funder-name:eq(${index})').text().trim()
  [Return]  ${value}

izi знайти на сторінці тендера поле funders[${index}].address.countryName
  ${value}=  izi get countryname from iziAddressField
  ...  iziAddressFieldSelector=funders-info .funders-info__funder-name:eq(${index})~info-popup .info-popup__popup p strong:contains(Місцезнаходження)+span
  [Return]  ${value}

izi знайти на сторінці тендера поле funders[${index}].address.locality
  ${value}=  izi get locality from iziAddressField
  ...  iziAddressFieldSelector=funders-info .funders-info__funder-name:eq(${index})~info-popup .info-popup__popup p strong:contains(Місцезнаходження)+span
  [Return]  ${value}

izi знайти на сторінці тендера поле funders[${index}].address.postalCode
  ${value}=  izi get postalCode from iziAddressField
  ...  iziAddressFieldSelector=funders-info .funders-info__funder-name:eq(${index})~info-popup .info-popup__popup p strong:contains(Місцезнаходження)+span
  [Return]  ${value}

izi знайти на сторінці тендера поле funders[${index}].address.region
  ${value}=  izi get region from iziAddressField
  ...  iziAddressFieldSelector=funders-info .funders-info__funder-name:eq(${index})~info-popup .info-popup__popup p strong:contains(Місцезнаходження)+span
  [Return]  ${value}

izi знайти на сторінці тендера поле funders[${index}].address.streetAddress
  ${value}=  izi get streetAddress from iziAddressField
  ...  iziAddressFieldSelector=funders-info .funders-info__funder-name:eq(${index})~info-popup .info-popup__popup p strong:contains(Місцезнаходження)+span
  [Return]  ${value}

izi знайти на сторінці тендера поле funders[${index}].contactPoint.url
  ${value}=  Execute Javascript  return $('funders-info .funders-info__funder-name:eq(${index})~info-popup .info-popup__popup p strong:contains(Url)+span').text()
  [Return]  ${value}

izi знайти на сторінці тендера поле funders[${index}].identifier.id
  ${value}=  Execute Javascript  return $('funders-info .funders-info__funder-name:eq(${index})~info-popup .info-popup__popup p strong:contains(Код ЄДРПОУ)+span').text()
  [Return]  ${value}

izi знайти на сторінці тендера поле funders[${index}].identifier.legalName
  ${value}=  Execute Javascript  return $('funders-info .funders-info__funder-name:eq(${index})~info-popup .info-popup__popup p strong:contains(Назва)+span').text()
  [Return]  ${value}

izi знайти на сторінці тендера поле funders[${index}].identifier.scheme
  ${value}=  Execute Javascript  return $('funders-info .funders-info__funder-name:eq(${index})~info-popup .info-popup__popup p strong:contains(Схема Ідентифікації)+span').text()
  [Return]  ${value}

izi знайти на сторінці тендера поле milestones[${index}].code
  ${value}=  Execute Javascript  return $('.milestones-info__milestone-row').eq(${index}).attr('przMilestoneCode')
  [Return]  ${value}

izi знайти на сторінці тендера поле milestones[${index}].title
  ${value}=  Execute Javascript  return $('.milestones-info__milestone-row').eq(${index}).attr('przMilestoneTitle')
  [Return]  ${value}

izi знайти на сторінці тендера поле milestones[${index}].percentage
  ${value}=  Execute Javascript  return +$('.milestones-info__milestone-row').eq(${index}).attr('przMilestonePercentage')
  [Return]  ${value}

izi знайти на сторінці тендера поле milestones[${index}].duration.days
  ${value}=  Execute Javascript  return +$('.milestones-info__milestone-row').eq(${index}).attr('przMilestoneDurationDays')
  [Return]  ${value}

izi знайти на сторінці тендера поле milestones[${index}].duration.type
  ${value}=  Execute Javascript  return $('.milestones-info__milestone-row').eq(${index}).attr('przMilestoneDurationType')
  [Return]  ${value}

izi знайти на сторінці тендера поле mainProcurementCategory
  ${value}=  Execute Javascript  return $('.tender-info-notes__procurementCategory .notes__value').text().trim()
  ${value}=  izi_service.get_prozorro_procurementCategory_by_izi_procurementCategoryText  ${value}
  [Return]  ${value}

izi знайти на сторінці тендера поле lots[${lotIndex}].title
  izi обрати лот ${lotIndex}
  ${value}=  Execute Javascript  return $('.tender-lot .tender-lot-description__title').first().text().trim()
  [Return]  ${value}

izi знайти на сторінці тендера поле features[${index}].title
  ${value}=  Execute Javascript  return $('winner-criterias .winner-criterias__row:eq(${index}) .winner-criterias__name').text().trim()
  [Return]  ${value}

izi знайти на сторінці тендера поле features[${index}].description
  ${value}=  Execute Javascript  return $('winner-criterias .winner-criterias__row:eq(${index}) .winner-criterias__name-col info-popup span div span').text().trim()
  [Return]  ${value}

izi знайти на сторінці тендера поле contracts[${index}].dateSigned
  ${value}=  Execute Javascript  return $('contract-info:eq(${index}) .contract-info__date-signed').attr('przDateSigned') || $('contract-info:eq(0) .contract-info__date-signed').attr('przDateSigned')
  ${value}=  izi convert izi date to prozorro date  ${value}
  [Return]  ${value}

izi знайти на сторінці тендера поле documentOf документу ${doc_id}
  ${attribute}=  Set Variable  przDocumentOf
  ${value}=  Run Keyword  izi find objectId element attribute  attribute=${attribute}  objectId=${doc_id}
  ...  wrapperElSelector=documents-versions .documents-versions__row
  ...  elThatHasObjectIdSelector=.documents-versions__name-val
  ...  elThatHasValueSelector=.documents-versions__name
  [Return]  ${value}

izi знайти на сторінці тендера поле maxAwardsCount
  ${value}=  Execute Javascript  return $('.tender-info-notes ul li:contains(Максимальна кількість учасників) span').text().trim()
  ${value}=  Convert To Number  ${value}
  [Return]  ${value}

izi знайти на сторінці тендера поле agreementDuration
  ${attribute}=  Set Variable  przAgreementDuration
  ${value}=  Execute Javascript  return $('.tender-info-notes ul li[${attribute}]').attr('${attribute}')
  [Return]  ${value}

izi знайти на сторінці тендера поле agreements[${index}].status
  ${value}=  Execute Javascript  return $('.contract-info__status').text().trim()
  ${value}=  izi_service.convert_izi_string_to_prozorro_string  ${value}
  [Return]  ${value}

izi знайти на сторінці тендера поле agreements[${index}].agreementID
  ${value}=  Execute Javascript  return $('.agreement-info:eq(${index}) .contract-info__topic span:first').text().split(" ").pop() || $('.agreement-info:eq(0) .contract-info__topic span:first').text().split(" ").pop()
  [Return]  ${value}

izi чи я на сторінці угоди ${agreement_uaid}
  ${currentPageAgreementCode}=  Execute Javascript  return $('agreement-page[agreementCode]').attr('agreementCode')
  Return From Keyword If  '${currentPageAgreementCode}' == '${agreement_uaid}'  TRUE
  Return From Keyword  FALSE

izi перейти на сторінку угоди
  [Arguments]  ${agreement_uaid}
  izi sync agreement  ${agreement_uaid}
  ${isAmOnPage}=  izi чи я на сторінці угоди ${agreement_uaid}
  Run Keyword If  '${isAmOnPage}' == 'FALSE'  Run Keywords
  ...  Go to  ${BROKERS['izi'].homepage}/agreements/${agreement_uaid}
  ...  AND  Wait Until Page Contains Element  css=agreement-page  15
  Sleep  2s
  ${factDateModified}=  izi get agreement dateModified  ${agreement_uaid}
  ${factDateModified}=  Fetch From Left  ${factDateModified}  .
  ${pageDateModified}=  Execute Javascript  return $('agreement-page[datemodified]').attr('datemodified')
  ${pageDateModified}=  Fetch From Left  ${pageDateModified}  .
  Log  agreement modified date="${factDateModified}"  DEBUG
  Log  page agreement modified date="${pageDateModified}"  DEBUG
  Return From Keyword If  '${factDateModified}' == '${pageDateModified}'
  Log  agreement was modified, reloading page....
  Reload Page
  Wait Until Page Contains Element  css=agreement-page  15
  Sleep  500ms

izi знайти на сторінці угоди поле changes[${changeIndex}].rationaleType
  ${value}=  Execute Javascript  return $("p").has("strong:contains(Обґрунтування змін згідно закону)").eq(${changeIndex}).text().split(":").pop().trim()
  ${value}=  izi_service.convert_izi_string_to_prozorro_string  ${value}
  [Return]  ${value}

izi знайти на сторінці угоди поле changes[${changeIndex}].rationale
  ${value}=  Execute Javascript  return $("p").has("strong:contains(Опис причин внесення змін)").eq(${changeIndex}).text().split(":").pop().trim()
  [Return]  ${value}

izi знайти на сторінці угоди поле changes[${changeIndex}].status
  ${value}=  Execute Javascript  return $(".contract-page__status").has("strong:contains(Статус додаткової угоди)").eq(${changeIndex}).find(".contract-page__status-item").text().split(":").pop().trim()
  ${value}=  izi_service.convert_izi_string_to_prozorro_string  ${value}
  [Return]  ${value}

izi знайти на сторінці тендера поле minimalStepPercentage
  ${attribute}=  Set Variable  przMinimalStepPercentage
  ${value}=  Execute Javascript  return +$('tender-lot-info notes li[${attribute}]').attr('${attribute}')
  [Return]  ${value}

izi знайти на сторінці лоту ${lotIndex} поле minimalStepPercentage
  Run keyword and return  izi знайти на сторінці тендера поле lots[${lotIndex}].minimalStepPercentage

izi знайти на сторінці тендера поле lots[${lotIndex}].minimalStepPercentage
  izi обрати лот ${lotIndex}
  ${attribute}=  Set Variable  przMinimalStepPercentage
  ${value}=  Execute Javascript  return +$('tender-lot-info notes li[${attribute}]').attr('${attribute}')
  [Return]  ${value}

izi знайти на сторінці тендера поле NBUdiscountRate
  ${attribute}=  Set Variable  przNbuDiscountRate
  ${value}=  Execute Javascript  return +$('tender-lot-info notes li[${attribute}]').attr('${attribute}')
  [Return]  ${value}

izi знайти на сторінці тендера поле fundingKind
  ${attribute}=  Set Variable  przFundingKind
  ${value}=  Execute Javascript  return $('tender-lot-info notes li[${attribute}]').attr('${attribute}')
  [Return]  ${value}

izi знайти на сторінці лоту ${lotIndex} поле fundingKind
  izi обрати лот ${lotIndex}
  ${attribute}=  Set Variable  przFundingKind
  ${value}=  Execute Javascript  return $('tender-lot-info notes li[${attribute}]').attr('${attribute}')
  [Return]  ${value}

izi знайти на сторінці тендера поле yearlyPaymentsPercentageRange
  ${attribute}=  Set Variable  przYearlyPaymentsPercentageRange
  ${value}=  Execute Javascript  return +$('tender-lot-info notes li[${attribute}]').attr('${attribute}')
  [Return]  ${value}

izi знайти на сторінці лоту ${lotIndex} поле yearlyPaymentsPercentageRange
  Run keyword and return  izi знайти на сторінці тендера поле lots[${lotIndex}].yearlyPaymentsPercentageRange

izi знайти на сторінці тендера поле lots[${lotIndex}].yearlyPaymentsPercentageRange
  izi обрати лот ${lotIndex}
  ${attribute}=  Set Variable  przYearlyPaymentsPercentageRange
  ${value}=  Execute Javascript  return +$('tender-lot-info notes li[${attribute}]').attr('${attribute}')
  [Return]  ${value}

izi перейти на сторінку плану
  [Arguments]  ${planUaId}
  izi sync plan  ${planUaId}
  ${isAmOnPage}=  izi чи я на сторінці плану ${planUaId}
  Run Keyword If  '${isAmOnPage}' == 'FALSE'  izi знайти план та перейти на сторінку  ${planUaId}
  Sleep  2s

izi чи я на сторінці плану ${planUaId}
  ${currentPlanCode}=  Execute Javascript  return $('plan-page[planCode]').attr('planCode')
  Return From Keyword If  '${currentPlanCode}' == '${planUaId}'  TRUE
  Return From Keyword  FALSE

izi перейти на сторінку пошуку плану
  [Arguments]  ${searchText}
  Go to  ${BROKERS['izi'].homepage}/plans?searchText=${searchText}
  Wait Until Page Contains Element  css=search-results  15
  Sleep  500ms

izi знайти план та перейти на сторінку
  [Arguments]  ${planUaId}
  izi перейти на сторінку пошуку плану  searchText=${planUaId}
  Sleep  1s
  Click Element  css=search-results plan-info:first-child .tender-info__footer a
  Wait Until Page Contains Element  css=plan-page  15
  Sleep  2s

izi знайти на сторінці тендера поле auctionPeriod.startDate
  ${value}=  Execute Javascript  return $('.tender-lot-status__auction-status').attr('auctionStartDate')
  ${value}=  izi convert izi date to prozorro date  ${value}
  [Return]  ${value}

izi знайти на сторінці лоту ${lotIndex} поле auctionPeriod.startDate
  izi обрати лот ${lotIndex}
  Run Keyword And Return  izi знайти на сторінці тендера поле auctionPeriod.startDate

izi знайти на сторінці тендера поле lots[${lotIndex}].auctionPeriod.startDate
  Run Keyword And Return  izi знайти на сторінці лоту ${lotIndex} поле auctionPeriod.startDate

izi знайти на сторінці плану поле tender.procurementMethodType
  ${value}=  Execute Javascript  return $('.notes:not(.mobile) ul li strong:contains(Тип процедури:)+span').text().trim()
  ${value}=  izi_service.get_prozorro_pmtype_by_izi_pmtext  ${value}
  [Return]  ${value}

izi знайти на сторінці плану поле budget.amount
  ${value}=  Execute Javascript  return $(".tender-details__price-val").first().text().trim()
  ${value}=  izi convert izi number to prozorro number  ${value}
  [Return]  ${value}

izi знайти на сторінці плану поле budget.description
  ${value}=  Execute Javascript  return $('.contract-page__preface:first').text().trim()
  [Return]  ${value}

izi знайти на сторінці плану поле budget.currency
  ${value}=  Execute Javascript  return $(".tender-details__price-curr").text().trim()
  ${value}=  get_prozorro_curr_by_izi_curr  ${value}
  [Return]  ${value}

izi знайти на сторінці плану поле procuringEntity.name
  Log  TODO
  ${value}=  Execute Javascript  return $('.tender-details .tender-details__info p:has(strong:contains(Замовник:))+p').text().trim()
  [Return]  ${value}

izi знайти на сторінці плану поле procuringEntity.identifier.scheme
  ${value}=  Execute Javascript  return $('.tender-details .tender-details__more-info dl:has(strong:contains(Схема Ідентифікації:)) dd').text().trim()
  [Return]  ${value}

izi знайти на сторінці плану поле procuringEntity.identifier.id
  ${value}=  Execute Javascript  return $('.tender-details .tender-details__more-info dl:has(dt:contains(Код ЄДРПОУ:)) dd').text().trim()
  [Return]  ${value}

izi знайти на сторінці плану поле procuringEntity.identifier.legalName
  ${value}=  Execute Javascript  return $('.tender-details .tender-details__info p:has(strong:contains(Замовник:))+p').text().trim()
  [Return]  ${value}

izi знайти на сторінці плану поле classification.description
  Log  TODO
  ${value}=  Execute Javascript  return $('.notes ul li strong:contains(Код ДК021):first+span').text().trim()
  [Return]  ${value}

izi знайти на сторінці плану поле classification.scheme
  Log  TODO
  ${value}=  Execute Javascript  return $('.notes ul li strong:contains(Код ДК021):first').text().trim().slice(3, -1).trim()
  [Return]  ${value}

izi знайти на сторінці плану поле classification.id
  ${value}=  Execute Javascript  return null
  [Return]  ${value}

izi знайти на сторінці плану поле items[${item_index}].description
  ${value}=  Execute Javascript  return $('.items-info__row:eq(${item_index}) .items-info__name .items-info__name-desc').text().trim()
  [Return]  ${value}

izi знайти на сторінці плану поле items[${item_index}].quantity
  ${value}=  Execute Javascript  return $('.items-info__row:eq(${item_index}) .items-info__number .items-info__uqnt').text().trim()
  ${value}=  izi convert izi number to prozorro number  ${value}
  [Return]  ${value}

izi знайти на сторінці плану поле items[${item_index}].deliveryDate.endDate
  ${value}=  Execute Javascript  return $('.items-info__row:eq(${item_index}) .items-info__popup p:contains(Період доставки: до) span').text().trim()
  ${value}=  izi convert izi date to prozorro date  ${value}
  [Return]  ${value}

izi знайти на сторінці плану поле items[${item_index}].unit.code
  ${value}=  Execute Javascript  return $('.items-info__row:eq(${item_index}) .items-info__number .items-info__uname').attr('przItemUnitCode').trim()
  [Return]  ${value}

izi знайти на сторінці плану поле items[${item_index}].unit.name
  ${value}=  Execute Javascript  return $('.items-info__row:eq(${item_index}) .items-info__number .items-info__uname').text().trim()
  [Return]  ${value}

izi знайти на сторінці плану поле items[${item_index}].classification.description
  ${value}=  Execute Javascript  return $('.items-info__row:eq(${item_index}) .items-info__popup .items-info__classification:first .items-info__classification-descr').text().trim()
  [Return]  ${value}

izi знайти на сторінці плану поле items[${item_index}].classification.scheme
  ${value}=  Execute Javascript  return $('.items-info__row:eq(${item_index}) .items-info__popup .items-info__classification:first .items-info__classification-scheme').text().trim()
  [Return]  ${value}

izi знайти на сторінці плану поле items[${item_index}].classification.id
  ${value}=  Execute Javascript  return $('.items-info__row:eq(${item_index}) .items-info__popup .items-info__classification:first .items-info__classification-id').text().trim()
  [Return]  ${value}

izi знайти на сторінці тендера поле items[${item_index}].classification.scheme
  ${value}=  izi знайти на сторінці тендера поле classification.scheme предмету ${item_index}
  [Return]  ${value}

izi знайти на сторінці тендера поле items[${item_index}].quantity
  ${value}=  izi знайти на сторінці тендера поле quantity предмету ${item_index}
  [Return]  ${value}

izi знайти на сторінці тендера поле lots[${lot_index}].value.amount
  ${value}=  izi знайти на сторінці лоту ${lot_index} поле value.amount
  [Return]  ${value}

izi знайти на сторінці тендера поле lots[${lot_index}].minimalStep.amount
  ${value}=  izi знайти на сторінці лоту ${lot_index} поле minimalStep.amount
  [Return]  ${value}
