# 国家过滤器



配置服务器允许哪些地区的玩家加入，可配置黑名单和白名单。

```bash
// 2位国家码黑名单(,分隔).
// -
// Default: ""
l4d2_country_black_list ""

// 2位国家码白名单(,分隔).
// -
// Default: ""
l4d2_country_white_list ""
```



如果黑名单和白名单都配置了, 白名单的优先级更高.

配置的2位国家码以英文逗号(,)分隔

例: "AA,BB,CC"



2位国家码参考：

```
[List of CountryCodes]
----------------------
AD -> Andorra
AE -> United Arab Emirates (The)
AF -> Afghanistan
AG -> Antigua and Barbuda
AI -> Anguilla
AL -> Albania
AM -> Armenia
AO -> Angola
AQ -> Antarctica
AR -> Argentina
AS -> American Samoa
AT -> Austria
AU -> Australia
AW -> Aruba
AX -> Åland Islands
AZ -> Azerbaijan
BA -> Bosnia and Herzegovina
BB -> Barbados
BD -> Bangladesh
BE -> Belgium
BF -> Burkina Faso
BG -> Bulgaria
BH -> Bahrain
BI -> Burundi
BJ -> Benin
BL -> Saint Barthélemy
BM -> Bermuda
BN -> Brunei Darussalam
BO -> Bolivia (Plurinational State of)
BQ -> Bonaire, Sint Eustatius and Saba
BR -> Brazil
BS -> Bahamas (The)
BT -> Bhutan
BV -> Bouvet Island
BW -> Botswana
BY -> Belarus
BZ -> Belize
CA -> Canada
CC -> Cocos (Keeling) Islands (The)
CD -> Congo (The Democratic Republic of The)
CF -> Central African Republic (The)
CG -> Congo (The)
CH -> Switzerland
CI -> Côte d'Ivoire
CK -> Cook Islands (The)
CL -> Chile
CM -> Cameroon
CN -> China
CO -> Colombia
CR -> Costa Rica
CU -> Cuba
CV -> Cabo Verde
CW -> Curaçao
CX -> Christmas Island
CY -> Cyprus
CZ -> Czechia
DE -> Germany
DJ -> Djibouti
DK -> Denmark
DM -> Dominica
DO -> Dominican Republic (The)
DZ -> Algeria
EC -> Ecuador
EE -> Estonia
EG -> Egypt
EH -> Western Sahara
ER -> Eritrea
ES -> Spain
ET -> Ethiopia
FI -> Finland
FJ -> Fiji
FK -> Falkland Islands (The) [Malvinas]
FM -> Micronesia (Federated States of)
FO -> Faroe Islands (The)
FR -> France
GA -> Gabon
GB -> United Kingdom of Great Britain and NorThern Ireland (The)
GD -> Grenada
GE -> Georgia
GF -> French Guiana
GG -> Guernsey
GH -> Ghana
GI -> Gibraltar
GL -> Greenland
GM -> Gambia (The)
GN -> Guinea
GP -> Guadeloupe
GQ -> Equatorial Guinea
GR -> Greece
GS -> South Georgia and The South Sandwich Islands
GT -> Guatemala
GU -> Guam
GW -> Guinea-Bissau
GY -> Guyana
HK -> Hong Kong (SAR of China)
HM -> Heard Island and McDonald Islands
HN -> Honduras
HR -> Croatia
HT -> Haiti
HU -> Hungary
ID -> Indonesia
IE -> Ireland
IL -> Israel
IM -> Isle of Man
IN -> India
IO -> British Indian Ocean Territory (The)
IQ -> Iraq
IR -> Iran (Islamic Republic of)
IS -> Iceland
IT -> Italy
JE -> Jersey
JM -> Jamaica
JO -> Jordan
JP -> Japan
KE -> Kenya
KG -> Kyrgyzstan
KH -> Cambodia
KI -> Kiribati
KM -> Comoros (The)
KN -> Saint Kitts and Nevis
KP -> Korea (The Democratic People's Republic of)
KR -> Korea (The Republic of)
KW -> Kuwait
KY -> Cayman Islands (The)
KZ -> Kazakhstan
LA -> Lao People's Democratic Republic (The)
LB -> Lebanon
LC -> Saint Lucia
LI -> Liechtenstein
LK -> Sri Lanka
LR -> Liberia
LS -> Lesotho
LT -> Lithuania
LU -> Luxembourg
LV -> Latvia
LY -> Libya
MA -> Morocco
MC -> Monaco
MD -> Moldova (The Republic of)
ME -> Montenegro
MF -> Saint Martin (French part)
MG -> Madagascar
MH -> Marshall Islands (The)
MK -> Republic of North Macedonia
ML -> Mali
MM -> Myanmar
MN -> Mongolia
MO -> Macao (SAR of China)
MP -> NorThern Mariana Islands (The)
MQ -> Martinique
MR -> Mauritania
MS -> Montserrat
MT -> Malta
MU -> Mauritius
MV -> Maldives
MW -> Malawi
MX -> Mexico
MY -> Malaysia
MZ -> Mozambique
NA -> Namibia
NC -> New Caledonia
NE -> Niger (The)
NF -> Norfolk Island
NG -> Nigeria
NI -> Nicaragua
NL -> NeTherlands (The)
NO -> Norway
NP -> Nepal
NR -> Nauru
NU -> Niue
NZ -> New Zealand
OM -> Oman
PA -> Panama
PE -> Peru
PF -> French Polynesia
PG -> Papua New Guinea
PH -> Philippines (The)
PK -> Pakistan
PL -> Poland
PM -> Saint Pierre and Miquelon
PN -> Pitcairn
PR -> Puerto Rico
PS -> Palestine, State of
PT -> Portugal
PW -> Palau
PY -> Paraguay
QA -> Qatar
RE -> Réunion
RO -> Romania
RS -> Serbia
RU -> Russian Federation (The)
RW -> Rwanda
SA -> Saudi Arabia
SB -> Solomon Islands
SC -> Seychelles
SD -> Sudan (The)
SE -> Sweden
SG -> Singapore
SH -> Saint Helena, Ascension and Tristan da Cunha
SI -> Slovenia
SJ -> Svalbard and Jan Mayen
SK -> Slovakia
SL -> Sierra Leone
SM -> San Marino
SN -> Senegal
SO -> Somalia
SR -> Suriname
SS -> South Sudan
ST -> Sao Tome and Principe
SV -> El Salvador
SX -> Sint Maarten (Dutch part)
SY -> Syrian Arab Republic
SZ -> Eswatini
TC -> Turks and Caicos Islands (The)
TD -> Chad
TF -> French SouThern Territories (The)
TG -> Togo
TH -> Thailand
TJ -> Tajikistan
TK -> Tokelau
TL -> Timor-Leste
TM -> Turkmenistan
TN -> Tunisia
TO -> Tonga
TR -> Turkey
TT -> Trinidad and Tobago
TV -> Tuvalu
TW -> Taiwan (Province of China)
TZ -> Tanzania, United Republic of
UA -> Ukraine
UG -> Uganda
UM -> United States Minor Outlying Islands (The)
US -> United States of America (The)
UY -> Uruguay
UZ -> Uzbekistan
VA -> Holy See (The)
VC -> Saint Vincent and The Grenadines
VE -> Venezuela (Bolivarian Republic of)
VG -> Virgin Islands (British)
VI -> Virgin Islands (U.S.)
VN -> Viet Nam
VU -> Vanuatu
WF -> Wallis and Futuna
WS -> Samoa
YE -> Yemen
YT -> Mayotte
ZA -> South Africa
ZM -> Zambia
ZW -> Zimbabwe
```
