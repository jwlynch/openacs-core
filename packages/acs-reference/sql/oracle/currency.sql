-- packages/acs-reference/sql/currency.sql
--
-- @author jon@arsdigita.com
-- @creation-date 2000-11-29
-- @cvs-id $Id$


create table currencies (
    -- since currencies 
    -- 3 char alphabetic
    codeA char(3)
        constraint currencies_code_a_pk
        primary key,
    -- this is the currency #
    codeN number,
    -- this is the minor unit
    -- not sure of the use but it is in the standar
    minor_unit char(1),
    -- explanation per iso
    note varchar(4000),
    -- this violates 3nf but is used for 2 reasons
    -- 1. to help efficiency
    -- 2. to make querys not fail if no translation exists yet
    default_name varchar(100)
        constraint currencies_default_name_nn
        not null
);

comment on table currencies is '
    This is the currency code/english name table from ISO 4217.
';

-- add this table into the reference repository
declare
    v_id integer;
begin
    v_id := acs_reference.new(
        table_name     => 'CURRENCIES',
        source         => 'ISO 4217',
        source_url     => 'http://www.iso.ch',
        last_update    => to_date('2000-10-30','YYYY-MM-DD'),
        effective_date => sysdate
    );
commit;
end;
/

-- This is the translated mapping of country names

create table currency_names (
    -- lookup into the countries table
    codeA char(3)
        constraint currency_names_iso_fk
        references currencies (codeA),
    -- lookup into the language_codes table
    language_code 
        constraint currency_names_lang_code_fk
        references language_codes (language_id),
    -- the translated name
    name varchar(100)
);

comment on table currency_names is ' 
    This is the translated mapping of currency names and language codes.
';

comment on column currency_names.language_code is '
    This is a lookup into the iso languages table.
';

-- map from currencies to country
create table currency_country_map (
    codeA char(3)
        constraint currency_country_map_code_fk
        references currencies (codeA),
    -- foreign key to relate country to currency
    -- this can by one => many therefor can't be unique
    -- i.e. Cuba has USD and CUP
    country_code char(2)
        constraint curr_cntry_map_country_fk
        references countries (iso)
);

-- I will add a view to join this stuff later.

-- initial data for currencies

set feedback off;

insert into currencies values ('NA','',' ','','No universal currency');
insert into currencies values ('ADP','20','0','','Andorran Peseta');
insert into currencies values ('AED','784','2','','UAE Dirham');
insert into currencies values ('AFA','4','2','','Afghani');
insert into currencies values ('ALL','8','2','','Lek');
insert into currencies values ('AMD','51','2','','Armenian Dram');
insert into currencies values ('ANG','532','2','','Netherlands Antillan Guilder');
insert into currencies values ('AOA','973','2','','Kwanza');
insert into currencies values ('ARS','32','2','','Argentine Peso');
insert into currencies values ('ATS','40','2','','Schilling');
insert into currencies values ('AUD','36','2','','Australian Dollar');
insert into currencies values ('AWG','533','2','','Aruban Guilder');
insert into currencies values ('AZM','31','2','','Azerbaijanian Manat');
insert into currencies values ('BAM','977','2','','Convertible Marks');
insert into currencies values ('BBD','52','2','','Barbados Dollar');
insert into currencies values ('BDT','50','2','','Taka');
insert into currencies values ('BEF','56','0','','Belgian Franc');
insert into currencies values ('BGL','100','2','','Lev');
insert into currencies values ('BGN','975','2','','Bulgarian Lev');
insert into currencies values ('BHD','48','3','','Bahraini Dinar');
insert into currencies values ('BIF','108','0','','Burundi Franc');
insert into currencies values ('BMD','60','2','','Bermudian Dollar');
insert into currencies values ('BND','96','2','','Brunei Dollar');
insert into currencies values ('BOB','68','2','','Boliviano');
insert into currencies values ('BOV','984','2','','Mvdol');
insert into currencies values ('BRL','986','2','','Brazilian Real');
insert into currencies values ('BSD','44','2','','Bahamian Dollar');
insert into currencies values ('BTN','64','2','','Ngultrum');
insert into currencies values ('BWP','72','2','','Pula');
insert into currencies values ('BYB','112','0','','Belarussian Ruble');
insert into currencies values ('BYR','974','0','','Belarussian Ruble');
insert into currencies values ('BZD','84','2','','Belize Dollar');
insert into currencies values ('CAD','124','2','','Canadian Dollar');
insert into currencies values ('CDF','976','2','','Franc Congolais');
insert into currencies values ('CHF','756','2','','Swiss Franc');
insert into currencies values ('CLF','990','0','','Unidades de fomento');
insert into currencies values ('CLP','152','0','','Chilean Peso');
insert into currencies values ('CNY','156','2','','Yuan Renminbi');
insert into currencies values ('COP','170','2','','Colombian Peso');
insert into currencies values ('CRC','188','2','','Costa Rican Colon');
insert into currencies values ('CUP','192','2','','Cuban Peso');
insert into currencies values ('CVE','132','2','','Cape Verde Escudo');
insert into currencies values ('CYP','196','2','','Cyprus Pound');
insert into currencies values ('CZK','203','2','','Czech Koruna');
insert into currencies values ('DEM','276','2','','Deutsche Mark');
insert into currencies values ('DJF','262','0','','Djibouti Franc');
insert into currencies values ('DKK','208','2','','Danish Krone');
insert into currencies values ('DOP','214','2','','Dominican Peso');
insert into currencies values ('DZD','12','2','','Algerian Dinar');
insert into currencies values ('EEK','233','2','','Kroon');
insert into currencies values ('EGP','818','2','','Egyptian Pound');
insert into currencies values ('ERN','232','2','','Nakfa');
insert into currencies values ('ESP','724','0','','Spanish Peseta');
insert into currencies values ('ETB','230','2','','Ethiopian Birr');
insert into currencies values ('FIM','246','2','','Markka');
insert into currencies values ('FJD','242','2','','Fiji Dollar');
insert into currencies values ('FKP','238','2','','Falkland Islands Pound');
insert into currencies values ('FRF','250','2','','French Franc');
insert into currencies values ('GBP','826','2','','Pound Sterling');
insert into currencies values ('GEL','981','2','','Lari');
insert into currencies values ('GHC','288','2','','Cedi');
insert into currencies values ('GIP','292','2','','Gibraltar Pound');
insert into currencies values ('GMD','270','2','','Dalasi');
insert into currencies values ('GNF','324','0','','Guinea Franc');
insert into currencies values ('GRD','300','0','','Drachma');
insert into currencies values ('GTQ','320','2','','Quetzal');
insert into currencies values ('GWP','624','2','','Guinea-Bissau Peso');
insert into currencies values ('GYD','328','2','','Guyana Dollar');
insert into currencies values ('HKD','344','2','','Hong Kong Dollar');
insert into currencies values ('HNL','340','2','','Lempira');
insert into currencies values ('HRK','191','2','','Croatian kuna');
insert into currencies values ('HTG','332','2','','Gourde');
insert into currencies values ('HUF','348','2','','Forint');
insert into currencies values ('IDR','360','2','','Rupiah');
insert into currencies values ('IEP','372','2','','Irish Pound');
insert into currencies values ('ILS','376','2','','New Israeli Sheqel');
insert into currencies values ('INR','356','2','','Indian Rupee');
insert into currencies values ('IQD','368','3','','Iraqi Dinar');
insert into currencies values ('IRR','364','2','','Iranian Rial');
insert into currencies values ('ISK','352','2','','Iceland Krona');
insert into currencies values ('ITL','380','0','','Italian Lira');
insert into currencies values ('JMD','388','2','','Jamaican Dollar');
insert into currencies values ('JOD','400','3','','Jordanian Dinar');
insert into currencies values ('JPY','392','0','','Yen');
insert into currencies values ('KES','404','2','','Kenyan Shilling');
insert into currencies values ('KGS','417','2','','Som');
insert into currencies values ('KHR','116','2','','Riel');
insert into currencies values ('KMF','174','0','','Comoro Franc');
insert into currencies values ('KPW','408','2','','North Korean Won');
insert into currencies values ('KRW','410','0','','Won');
insert into currencies values ('KWD','414','3','','Kuwaiti Dinar');
insert into currencies values ('KYD','136','2','','Cayman Islands Dollar');
insert into currencies values ('KZT','398','2','','Tenge');
insert into currencies values ('LAK','418','2','','Kip');
insert into currencies values ('LBP','422','2','','Lebanese Pound');
insert into currencies values ('LKR','144','2','','Sri Lanka Rupee');
insert into currencies values ('LRD','430','2','','Liberian Dollar');
insert into currencies values ('LSL','426','2','','Loti');
insert into currencies values ('LTL','440','2','','Lithuanian Litus');
insert into currencies values ('LUF','442','0','','Luxembourg Franc');
insert into currencies values ('LVL','428','2','','Latvian Lats');
insert into currencies values ('LYD','434','3','','Lybian Dinar');
insert into currencies values ('MAD','504','2','','Moroccan Dirham');
insert into currencies values ('MDL','498','2','','Moldovan Leu');
insert into currencies values ('MGF','450','0','','Malagasy Franc');
insert into currencies values ('MKD','807','2','','Denar');
insert into currencies values ('MMK','104','2','','Kyat');
insert into currencies values ('MNT','496','2','','Tugrik');
insert into currencies values ('MOP','446','2','','Pataca');
insert into currencies values ('MRO','478','2','','Ouguiya');
insert into currencies values ('MTL','470','2','','Maltese Lira');
insert into currencies values ('MUR','480','2','','Mauritius Rupee');
insert into currencies values ('MVR','462','2','','Rufiyaa');
insert into currencies values ('MWK','454','2','','Kwacha');
insert into currencies values ('MXN','484','2','','Mexican Peso');
insert into currencies values ('MXV','979','2','','Mexican Unidad de Inversion (UDI)');
insert into currencies values ('MYR','458','2','','Malaysian Ringgit');
insert into currencies values ('MZM','508','2','','Metical');
insert into currencies values ('NAD','516','2','','Namibia Dollar');
insert into currencies values ('NGN','566','2','','Naira');
insert into currencies values ('NIO','558','2','','Cordoba Oro');
insert into currencies values ('NLG','528','2','','Netherlands Guilder');
insert into currencies values ('NOK','578','2','','Norvegian Krone');
insert into currencies values ('NPR','524','2','','Nepalese Rupee');
insert into currencies values ('NZD','554','2','','New Zealand Dollar');
insert into currencies values ('OMR','512','3','','Rial Omani');
insert into currencies values ('PAB','590','2','','Balboa');
insert into currencies values ('PEN','604','2','','Nuevo Sol');
insert into currencies values ('PGK','598','2','','Kina');
insert into currencies values ('PHP','608','2','','Philippine Peso');
insert into currencies values ('PKR','586','2','','Pakistan Rupee');
insert into currencies values ('PLN','985','2','','Zloty');
insert into currencies values ('PTE','620','0','','Portuguese Escudo');
insert into currencies values ('PYG','600','0','','Guarani');
insert into currencies values ('QAR','634','2','','Qatari Rial');
insert into currencies values ('ROL','642','2','','Leu');
insert into currencies values ('RUB','643','2','','Russian Ruble');
insert into currencies values ('RUR','810','2','','Russian Ruble');
insert into currencies values ('RWF','646','0','','Rwanda Franc');
insert into currencies values ('SAR','682','2','','Saudi Riyal');
insert into currencies values ('SBD','90','2','','Solomon Islands Dollar');
insert into currencies values ('SCR','690','2','','Seychelles Rupee');
insert into currencies values ('SDD','736','2','','Sudanese Dinar');
insert into currencies values ('SEK','752','2','','Swedish Krona');
insert into currencies values ('SGD','702','2','','Singapore Dollar');
insert into currencies values ('SHP','654','2','','Saint Helena Pound');
insert into currencies values ('SIT','705','2','','Tolar');
insert into currencies values ('SKK','703','2','','Slovak Koruna');
insert into currencies values ('SLL','694','2','','Leone');
insert into currencies values ('SOS','706','2','','Somali Shilling');
insert into currencies values ('SRG','740','2','','Suriname Guilder');
insert into currencies values ('STD','678','2','','Dobra');
insert into currencies values ('SVC','222','2','','El Salvador Colon');
insert into currencies values ('SYP','760','2','','Syrian Pound');
insert into currencies values ('SZL','748','2','','Lilangeni');
insert into currencies values ('THB','764','2','','Baht');
insert into currencies values ('TJR','762','0','','Tajik Ruble');
insert into currencies values ('TJS','972','0','','Somoni');
insert into currencies values ('TMM','795','2','','Manat');
insert into currencies values ('TND','788','3','','Tunisian Dinar');
insert into currencies values ('TOP','776','2','','Paaaaanga');
insert into currencies values ('TPE','626','0','','Timor Escudo');
insert into currencies values ('TRL','792','0','','Turkish Lira');
insert into currencies values ('TTD','780','2','','Trinidad and Tobago Dollar');
insert into currencies values ('TWD','901','2','','New Taiwan Dollar');
insert into currencies values ('TZS','834','2','','Tanzanian Shilling');
insert into currencies values ('UAH','980','2','','Hryvnia');
insert into currencies values ('UGX','800','2','','Uganda Shilling');
insert into currencies values ('USD','840','2','','US Dollar');
insert into currencies values ('USN','997','2','','US Dollar (Next day)');
insert into currencies values ('USS','998','2','','US Dollar (Same day)');
insert into currencies values ('UYU','858','2','','Peso Uruguayo');
insert into currencies values ('UZS','860','2','','Uzbekistan Sum');
insert into currencies values ('VEB','862','2','','Bolivar');
insert into currencies values ('VND','704','2','','Dong');
insert into currencies values ('VUV','548','0','','Vatu');
insert into currencies values ('WST','882','2','','Tala');
insert into currencies values ('XAF','950','0','','CFA Franc BEAC');
insert into currencies values ('XCD','951','2','','East Carribbean Dollar');
insert into currencies values ('XOF','952','0','','CFA Franc BCEAO');
insert into currencies values ('XPF','953','0','','CFP Franc');
insert into currencies values ('YER','886','2','','Yemeni Rial');
insert into currencies values ('YUM','891','2','','Yugoslavian Dinar');
insert into currencies values ('ZAR','710','2','','Rand');
insert into currencies values ('ZMK','894','2','','Kwacha');
insert into currencies values ('ZWD','716','2','','Zimbabwe Dollar');

set feedback on;
commit;






