# -*- coding: utf-8 -
import requests
import datetime
from pytz import timezone
import munch

def convert_izi_string_to_prozorro_string(string):
    return {
        u"грн.": u"UAH",
        u"Переможець":u"active",
        u"Не підписано":u"pending",
        u"Чинний": u"active",
        u"Вимогу задоволено":u"answered",
        u"true": True,
        u"false": False,
        u"Укладена рамкова угода":u"active",
        u"Підтверджена зміна": u"active",
        u"Скасована зміна": u"cancelled",
        u"Зміна ціни за одиницю товару (послуги) у зв'язку із зміною ставок податків і зборів пропорційно до змін таких ставок.;": u"taxRate",
        u"Зміна ціни за одиницю товару (послуги) не більше ніж на 10 відсотків у разі коливання ціни такого товару (послуги) на ринку.;": u"itemPriceVariation",
        u"Зміна встановленого згідно із законодавством органами державної статистики індексу споживчих цін, зміна курсу іноземної валюти, зміна біржових котирувань або показників Platts, регульованих цін (тарифів) і нормативів, які застосовуються в рамковій угоді, у разі встановлення порядку зміна ціни за одиницю товару (послуги) у рамковій угоді.;": u"thirdParty",
        u"Припинення участі у рамковій угоді учасника.;": u"partyWithdrawal"

    }.get(string, string)

def get(url):
    response = requests.get(url, timeout=10)
    return munch.munchify({
        "data": response.json(),
        "status_code": response.status_code
    })

def post(url, data = None):
    response = requests.post(url, data, timeout=10)
    return response

def get_time_with_offset(date):
    date_obj = datetime.datetime.strptime(date, "%Y-%m-%d %H:%M")
    time_zone = timezone('Europe/Kiev')
    localized_date = time_zone.localize(date_obj)
    return localized_date.strftime('%Y-%m-%d %H:%M:%S.%f%z')

def convert_dtstring_to_isoformat(date):
    date_obj = datetime.datetime.strptime(date, "%Y-%m-%d %H:%M")
    time_zone = timezone('Europe/Kiev')
    localized_date = time_zone.localize(date_obj)
    return localized_date.isoformat()

def get_izi_docType_by_prozorro_docType(przDocType):
    return {
        u"notice":u"1",
        u"biddingDocuments":u"2",
        u"bidding_documents": u"2",
        u"evaluationCriteria":u"4",
        u"clarifications":u"5",
        u"eligibilityCriteria":u"6",
        u"shortlistedFirms":u"7",
        u"riskProvisions":u"8",
        u"bidders":u"10",
        u"conflictOfInterest":u"11",
        u"debarments":u"12",
        u"contractProforma":u"13",
        u"technicalSpecifications":u"3",
        u"billOfQuantity":u"9",
        u"financial_documents": u"9",
        u"evaluationReports":u"14",
        u"winningBid":u"15",
        u"complaints":u"16",
        u"contractSigned":u"17",
        u"contractArrangements":u"18",
        u"contractSchedule":u"19",
        u"contractAnnexe":u"20",
        u"contractGuarantees":u"21",
        u"subContract":u"22",
        u"commercialProposal":u"23",
        u"qualificationDocuments":u"24",
        u"qualification_documents": u"24",
        u"eligibilityDocuments":u"25",
        u"eligibility_documents": u"25",
        u"tenderNotice":u"26",
        u"awardNotice":u"27",
        u"contractNotice":u"28",
        u"registerExtract":u"29"
    }.get(przDocType)

def get_prozorro_curr_by_izi_curr(iziCurr):
    return {
        u"грн.": u"UAH",
        u"$": u"USD",
        u"€": u"EUR",
        u"¥": u"JPY",
        u"£": u"GBP",
        u"Fr": u"CHF",
        u"¥": u"CNY",
        u"kr": u"SEK",
        u"kr": u"NOK",
        u"₩": u"KRW",
        u"₺": u"TRY",
        u"₹": u"INR",
        u"₽": u"RUB",
        u"R$": u"BRL",
        u"R": u"ZAR"
    }.get(iziCurr)

def get_prozorro_pmtype_by_izi_pmtext(pmtext):
    return {
        u"Допорогова закупівля": u"belowThreshold",
        u"Відкриті торги": u"aboveThresholdUA",
        u"Відкриті торги з публікацією на англійській мові": u"aboveThresholdEU",
        u"Переговорна процедура": u"negotiation",
        u"Переговорна процедура скорочена": u"negotiation.quick",
        u"Переговорна процедура для потреб оборони": u"aboveThresholdUA.defense",
        u"Конкурентний діалог": u"competitiveDialogueUA",
        u"Конкурентний діалог, етап #2": u"competitiveDialogueUA.stage2",
        u"Конкурентний діалог з публікацією на англійській мові": u"competitiveDialogueEU",
        u"Конкурентний діалог з публікацією на англійській мові, етап #2": u"competitiveDialogueEU.stage2",
        u"Звіт про укладений договір": u"reporting",
        u"Еско процедура": u"esco",
        u"Укладання рамкової угоди": u"closeFrameworkAgreementUA",
        u"Відбір для закупівлі за рамковою угодою": u"closeFrameworkAgreementSelectionUA"
    }.get(pmtext)


def get_prozorro_procurementCategory_by_izi_procurementCategoryText(text):
    return {
        u"Товари": u"goods",
        u"Послуги": u"services",
        u"Роботи": u"works",

    }.get(text)