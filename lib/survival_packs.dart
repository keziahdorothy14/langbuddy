import 'package:flutter/material.dart';
import 'dyslexia_helper.dart';
import 'sign_language.dart';
import 'main.dart'; // import speak function

class SurvivalPhrase {
  final String english;
  final String phonetic;
  final Map<String, String> translations;

  const SurvivalPhrase({
    required this.english,
    required this.phonetic,
    required this.translations,
  });
}

// Global dataset of curated, socially-useful survival phrases for 15+ languages
final List<SurvivalPhrase> healthcarePhrases = [
  const SurvivalPhrase(
    english: "I need a doctor.",
    phonetic: "ai need a DOK-ter",
    translations: {
      "English": "I need a doctor.",
      "French": "J'ai besoin d'un médecin.",
      "Spanish": "Necesito un médico.",
      "Hindi": "मुझे डॉक्टर की जरूरत है।",
      "German": "Ich brauche einen Arzt.",
      "Italian": "Ho bisogno di un dottore.",
      "Chinese": "我需要看医生。",
      "Japanese": "医者が必要です。",
      "Korean": "의사가 필요해요.",
      "Russian": "Мне нужен врач.",
      "Turkish": "Bir doktora ihtiyacım var.",
      "Vietnamese": "Tôi cần bác sĩ.",
      "Indonesian": "Saya butuh dokter.",
      "Dutch": "Ik heb een dokter nodig."
    },
  ),
  const SurvivalPhrase(
    english: "Where is the hospital?",
    phonetic: "wair iz the HOS-pi-tuhl",
    translations: {
      "English": "Where is the hospital?",
      "French": "Où est l'hôpital?",
      "Spanish": "¿Dónde está el hospital?",
      "Hindi": "अस्पताल कहाँ है?",
      "German": "Wo ist das Krankenhaus?",
      "Italian": "Dov'è l'ospedale?",
      "Chinese": "医院在哪里？",
      "Japanese": "病院はどこですか？",
      "Korean": "병원 어디에 있나요?",
      "Russian": "Где находится больница?",
      "Turkish": "Hastane nerede?",
      "Vietnamese": "Bệnh viện ở đâu?",
      "Indonesian": "Di mana rumah sakit?",
      "Dutch": "Waar is het ziekenhuis?"
    },
  ),
  const SurvivalPhrase(
    english: "I am in pain.",
    phonetic: "ai am in payn",
    translations: {
      "English": "I am in pain.",
      "French": "J'ai mal.",
      "Spanish": "Tengo dolor.",
      "Hindi": "मुझे दर्द हो रहा है।",
      "German": "Ich habe Schmerzen.",
      "Italian": "Ho dolore.",
      "Chinese": "我痛。",
      "Japanese": "痛いです。",
      "Korean": "아파요.",
      "Russian": "Мне больно.",
      "Turkish": "Acım var.",
      "Vietnamese": "Tôi bị đau.",
      "Indonesian": "Saya kesakitan.",
      "Dutch": "Ik heb pijn."
    },
  ),
  const SurvivalPhrase(
    english: "I have a fever.",
    phonetic: "ai hav a FEE-vur",
    translations: {
      "English": "I have a fever.",
      "French": "J'ai de la fièvre.",
      "Spanish": "Tengo fiebre.",
      "Hindi": "मुझे बुखार है।",
      "German": "Ich habe Fieber.",
      "Italian": "Ho la febbre.",
      "Chinese": "我发烧了。",
      "Japanese": "熱があります。",
      "Korean": "열이 나요.",
      "Russian": "У меня лихорадка.",
      "Turkish": "Ateşim var.",
      "Vietnamese": "Tôi bị sốt.",
      "Indonesian": "Saya demam.",
      "Dutch": "Ik heb koorts."
    },
  ),
  const SurvivalPhrase(
    english: "Where is the pharmacy?",
    phonetic: "wair iz the FAHR-muh-see",
    translations: {
      "English": "Where is the pharmacy?",
      "French": "Où est la pharmacie?",
      "Spanish": "¿Dónde está la farmacia?",
      "Hindi": "दवा की दुकान कहाँ है?",
      "German": "Wo ist die Apotheke?",
      "Italian": "Dov'è la farmacia?",
      "Chinese": "药房在哪里？",
      "Japanese": "薬局はどこですか？",
      "Korean": "약국이 어디에 있나요?",
      "Russian": "Где аптека?",
      "Turkish": "Eczane nerede?",
      "Vietnamese": "Hiệu thuốc ở đâu?",
      "Indonesian": "Di mana apotek?",
      "Dutch": "Waar is de apotheek?"
    },
  ),
  const SurvivalPhrase(
    english: "I am allergic to this medicine.",
    phonetic: "ai am uh-LUR-jik too thihs MED-uh-sin",
    translations: {
      "English": "I am allergic to this medicine.",
      "French": "Je suis allergique à ce médicament.",
      "Spanish": "Soy alérgico a este medicamento.",
      "Hindi": "मुझे इस दवा से एलर्जी है।",
      "German": "Ich bin allergisch gegen dieses Medikament.",
      "Italian": "Sono allergico a questo farmaco.",
      "Chinese": "我对这种药过敏。",
      "Japanese": "この薬にアレルギーがあります。",
      "Korean": "저는 이 약에 알레르기가 있어요.",
      "Russian": "У меня аллергия на это лекарство.",
      "Turkish": "Bu ilaca alerjim var.",
      "Vietnamese": "Tôi bị dị ứng với thuốc này.",
      "Indonesian": "Saya alergi obat ini.",
      "Dutch": "Ik ben allergisch voor dit medicijn."
    },
  ),
  const SurvivalPhrase(
    english: "Call an ambulance!",
    phonetic: "kawl an AM-byoo-luhns",
    translations: {
      "English": "Call an ambulance!",
      "French": "Appelez une ambulance!",
      "Spanish": "¡Llama a una ambulancia!",
      "Hindi": "एम्बुलेंस को बुलाओ!",
      "German": "Rufen Sie einen Krankenwagen!",
      "Italian": "Chiama un'ambulanza!",
      "Chinese": "叫救护车！",
      "Japanese": "救急車を呼んでください！",
      "Korean": "구급차를 불러주세요!",
      "Russian": "Вызовите скорую помощь!",
      "Turkish": "Ambulans çağırın!",
      "Vietnamese": "Gọi xe cấp cứu!",
      "Indonesian": "Panggil ambulans!",
      "Dutch": "Bel een ambulance!"
    },
  ),
  const SurvivalPhrase(
    english: "I feel dizzy.",
    phonetic: "ai feel DIZ-ee",
    translations: {
      "English": "I feel dizzy.",
      "French": "J'ai des vertiges.",
      "Spanish": "Me siento mareado.",
      "Hindi": "मुझे चक्कर आ रहे हैं।",
      "German": "Mir ist schwindelig.",
      "Italian": "Mi sento stordito.",
      "Chinese": "我感到头晕。",
      "Japanese": "めまいがします。",
      "Korean": "어지러워요.",
      "Russian": "У меня кружится голова.",
      "Turkish": "Başım dönüyor.",
      "Vietnamese": "Tôi thấy chóng mặt.",
      "Indonesian": "Saya merasa pusing.",
      "Dutch": "Ik ben duizelig."
    },
  ),
  const SurvivalPhrase(
    english: "Where is the emergency room?",
    phonetic: "wair iz the i-MUR-juhn-see room",
    translations: {
      "English": "Where is the emergency room?",
      "French": "Où sont les urgences?",
      "Spanish": "¿Dónde están las urgencias?",
      "Hindi": "आपत्कालीन कक्ष कहाँ है?",
      "German": "Wo ist die Notaufnahme?",
      "Italian": "Dov'è il pronto soccorso?",
      "Chinese": "急诊室在哪里？",
      "Japanese": "救急室はどこですか？",
      "Korean": "응급실이 어디에 있나요?",
      "Russian": "Где отделение приемного покоя?",
      "Turkish": "Acil servis nerede?",
      "Vietnamese": "Phòng cấp cứu ở đâu?",
      "Indonesian": "Di mana ruang gawat darurat?",
      "Dutch": "Waar is de spoedeisende hulp?"
    },
  ),
  const SurvivalPhrase(
    english: "I cannot breathe well.",
    phonetic: "ai KAN-not breeth wel",
    translations: {
      "English": "I cannot breathe well.",
      "French": "J'ai du mal à respirer.",
      "Spanish": "No puedo respirar bien.",
      "Hindi": "मुझे सांस लेने में तकलीफ हो रही है।",
      "German": "Ich kann schlecht atmen.",
      "Italian": "Non riesco a respirare bene.",
      "Chinese": "我呼吸困难。",
      "Japanese": "息がうまくできません。",
      "Korean": "숨을 잘 못 쉬겠어요.",
      "Russian": "Мне трудно дышать.",
      "Turkish": "Nefes almakta zorlanıyorum.",
      "Vietnamese": "Tôi khó thở.",
      "Indonesian": "Saya sulit bernapas.",
      "Dutch": "Ik kan niet goed ademen."
    },
  ),
  const SurvivalPhrase(
    english: "I need my medication.",
    phonetic: "ai need mai med-i-KAY-shuhn",
    translations: {
      "English": "I need my medication.",
      "French": "J'ai besoin de mes médicaments.",
      "Spanish": "Necesito mi medicina.",
      "Hindi": "मुझे मेरी दवाई चाहिए।",
      "German": "Ich brauche meine Medikamente.",
      "Italian": "Ho bisogno dei miei farmaci.",
      "Chinese": "我需要我的药物。",
      "Japanese": "薬が必要です。",
      "Korean": "약이 필요해요.",
      "Russian": "Мне нужны мои лекарства.",
      "Turkish": "İlacıma ihtiyacım var.",
      "Vietnamese": "Tôi cần thuốc của tôi.",
      "Indonesian": "Saya butuh obat saya.",
      "Dutch": "Ik heb mijn medicijnen nodig."
    },
  ),
];

final List<SurvivalPhrase> transportPhrases = [
  const SurvivalPhrase(
    english: "Where is the bus station?",
    phonetic: "wair iz the buhs STAY-shuhn",
    translations: {
      "English": "Where is the bus station?",
      "French": "Où est la gare routière?",
      "Spanish": "¿Dónde está la estación de autobuses?",
      "Hindi": "बस स्टेशन कहाँ है?",
      "German": "Wo ist der Busbahnhof?",
      "Italian": "Dov'è la stazione degli autobus?",
      "Chinese": "公交车站在哪里？",
      "Japanese": "バス停はどこですか？",
      "Korean": "버스 정류장이 어디인가요?",
      "Russian": "Где автовокзал?",
      "Turkish": "Otogar nerede?",
      "Vietnamese": "Trạm xe buýt ở đâu?",
      "Indonesian": "Di mana halte bus?",
      "Dutch": "Waar is het busstation?"
    },
  ),
  const SurvivalPhrase(
    english: "Where can I buy a ticket?",
    phonetic: "wair kan ai bai a TIK-it",
    translations: {
      "English": "Where can I buy a ticket?",
      "French": "Où puis-je acheter un billet?",
      "Spanish": "¿Dónde puedo comprar un billete?",
      "Hindi": "मैं टिकट कहाँ से खरीद सकता हूँ?",
      "German": "Wo kann ich eine Fahrkarte kaufen?",
      "Italian": "Dove posso comprare un biglietto?",
      "Chinese": "我在哪里可以买票？",
      "Japanese": "チケットはどこで買えますか？",
      "Korean": "표는 어디서 살 수 있나요?",
      "Russian": "Где я могу купить билет?",
      "Turkish": "Nereden bilet alabilirim?",
      "Vietnamese": "Tôi có thể mua vé ở đâu?",
      "Indonesian": "Di mana saya bisa membeli tiket?",
      "Dutch": "Waar kan ik een kaartje kopen?"
    },
  ),
  const SurvivalPhrase(
    english: "Please stop here.",
    phonetic: "pleez stop heer",
    translations: {
      "English": "Please stop here.",
      "French": "Arrêtez-vous ici, s'il vous plaît.",
      "Spanish": "Pare aquí, por favor.",
      "Hindi": "कृपया यहाँ रुकिए।",
      "German": "Bitte halten Sie hier an.",
      "Italian": "Fermati qui, per favore.",
      "Chinese": "请在这里停车。",
      "Japanese": "ここで止めてください。",
      "Korean": "여기서 멈춰주세요.",
      "Russian": "Остановитесь здесь, пожалуйста.",
      "Turkish": "Lütfen burada durun.",
      "Vietnamese": "Vui lòng dừng ở đây.",
      "Indonesian": "Tolong berhenti di sini.",
      "Dutch": "Stop hier alstublieft."
    },
  ),
  const SurvivalPhrase(
    english: "How much is the fare?",
    phonetic: "how muhch iz the fair",
    translations: {
      "English": "How much is the fare?",
      "French": "Combien coûte le trajet?",
      "Spanish": "¿Cuánto cuesta el billete?",
      "Hindi": "किराया कितना है?",
      "German": "Wie viel kostet die Fahrt?",
      "Italian": "Quanto costa la tariffa?",
      "Chinese": "票价是多少？",
      "Japanese": "運賃はいくらですか？",
      "Korean": "요금이 얼마인가요?",
      "Russian": "Сколько стоит проезд?",
      "Turkish": "Ücret ne kadar?",
      "Vietnamese": "Giá vé bao nhiêu?",
      "Indonesian": "Berapa tarifnya?",
      "Dutch": "Hoeveel kost de rit?"
    },
  ),
  const SurvivalPhrase(
    english: "Which train goes to the city center?",
    phonetic: "which trayn goz too the SIT-ee SEN-ter",
    translations: {
      "English": "Which train goes to the city center?",
      "French": "Quel train va au centre-ville?",
      "Spanish": "¿Qué tren va al centro de la ciudad?",
      "Hindi": "कौन सी ट्रेन शहर के केंद्र में जाती है?",
      "German": "Welcher Zug fährt ins Stadtzentrum?",
      "Italian": "Quale treno va in centro città?",
      "Chinese": "哪趟火车去市中心？",
      "Japanese": "市中心部に行く電車はどれですか？",
      "Korean": "시내로 가는 기차는 어느 것인가요?",
      "Russian": "Какой поезд идет в центр города?",
      "Turkish": "Şehir merkezine hangi tren gidiyor?",
      "Vietnamese": "Tàu nào đi vào trung tâm thành phố?",
      "Indonesian": "Kereta mana yang menuju pusat kota?",
      "Dutch": "Welke trein gaat naar het centrum?"
    },
  ),
  const SurvivalPhrase(
    english: "Take me to this address, please.",
    phonetic: "tayk mee too thihs uh-DRES pleez",
    translations: {
      "English": "Take me to this address, please.",
      "French": "Emmenez-moi à cette adresse, s'il vous plaît.",
      "Spanish": "Lléveme a esta dirección, por favor.",
      "Hindi": "कृपया मुझे इस पते पर ले चलिए।",
      "German": "Bringen Sie mich bitte zu dieser Adresse.",
      "Italian": "Mi porti a questo indirizzo, per favore.",
      "Chinese": "请带 me 去这个地址。",
      "Japanese": "この住所までお願いします。",
      "Korean": "이 주소로 가주세요.",
      "Russian": "Отвезите меня по этому адресу, пожалуйста.",
      "Turkish": "Lütfen beni bu adrese götürün.",
      "Vietnamese": "Vui lòng đưa tôi đến địa chỉ này.",
      "Indonesian": "Tolong antar saya ke alamat ini.",
      "Dutch": "Breng me alstublieft naar dit adres."
    },
  ),
  const SurvivalPhrase(
    english: "What time is the next bus?",
    phonetic: "wht tym iz the nekst buhs",
    translations: {
      "English": "What time is the next bus?",
      "French": "À quelle heure est le prochain bus?",
      "Spanish": "¿A qué hora es el próximo autobús?",
      "Hindi": "अगली बस कितने बजे है?",
      "German": "Wann fährt der nächste Bus?",
      "Italian": "A che ora è il prossimo autobus?",
      "Chinese": "下一班公交车是什么时候？",
      "Japanese": "次のバスは何時ですか？",
      "Korean": "다음 버스는 몇 시인가요?",
      "Russian": "Во сколько следующий автобус?",
      "Turkish": "Sonraki otobüs saat kaçta?",
      "Vietnamese": "Xe buýt tiếp theo lúc mấy giờ?",
      "Indonesian": "Jam berapa bus berikutnya?",
      "Dutch": "Hoe laat gaat de volgende bus?"
    },
  ),
  const SurvivalPhrase(
    english: "Where is the taxi stand?",
    phonetic: "wair iz the TAK-see stand",
    translations: {
      "English": "Where is the taxi stand?",
      "French": "Où est la station de taxis?",
      "Spanish": "¿Dónde está la parada de taxis?",
      "Hindi": "टैक्सी स्टैंड कहाँ है?",
      "German": "Wo ist der Taxistand?",
      "Italian": "Dov'è la stazione dei taxi?",
      "Chinese": "出租车车站在哪里？",
      "Japanese": "タクシー乗り場はどこですか？",
      "Korean": "택시 승강장이 어디인가요?",
      "Russian": "Где стоянка такси?",
      "Turkish": "Taksi durağı nerede?",
      "Vietnamese": "Trạm taxi ở đâu?",
      "Indonesian": "Di mana pangkalan taksi?",
      "Dutch": "Waar is de taxistandplaats?"
    },
  ),
  const SurvivalPhrase(
    english: "Is this seat taken?",
    phonetic: "iz thihs seet TAY-kuhn",
    translations: {
      "English": "Is this seat taken?",
      "French": "Ce siège est-il pris?",
      "Spanish": "¿Está ocupado este asiento?",
      "Hindi": "क्या यह सीट खाली है?",
      "German": "Ist dieser Platz frei?",
      "Italian": "È libero questo posto?",
      "Chinese": "这个座位有人吗？",
      "Japanese": "この席は空いていますか？",
      "Korean": "이 자리에 사람 있나요?",
      "Russian": "Это место занято?",
      "Turkish": "Bu koltuk boş mu?",
      "Vietnamese": "Chỗ này có ai ngồi chưa?",
      "Indonesian": "Apakah kursi ini kosong?",
      "Dutch": "Is deze stoel bezet?"
    },
  ),
  const SurvivalPhrase(
    english: "I am lost.",
    phonetic: "ai am lost",
    translations: {
      "English": "I am lost.",
      "French": "Je suis perdu.",
      "Spanish": "Estoy perdido.",
      "Hindi": "मैं रास्ता भटक गया हूँ।",
      "German": "Ich habe mich verlaufen.",
      "Italian": "Mi sono perso.",
      "Chinese": "我迷路了。",
      "Japanese": "迷子になりました。",
      "Korean": "길을 잃었어요.",
      "Russian": "Я заблудился.",
      "Turkish": "Kayboldum.",
      "Vietnamese": "Tôi bị lạc đường.",
      "Indonesian": "Saya tersesat.",
      "Dutch": "Ik ben verdwaald."
    },
  ),
];

final List<SurvivalPhrase> legalPhrases = [
  const SurvivalPhrase(
    english: "I need help.",
    phonetic: "ai need help",
    translations: {
      "English": "I need help.",
      "French": "J'ai besoin d'aide.",
      "Spanish": "Necesito ayuda.",
      "Hindi": "मुझे मदद चाहिए।",
      "German": "Ich brauche Hilfe.",
      "Italian": "Ho bisogno di aiuto.",
      "Chinese": "我需要帮助。",
      "Japanese": "助けが必要です。",
      "Korean": "도움이 필요해요.",
      "Russian": "Мне нужна помощь.",
      "Turkish": "Yardıma ihtiyacım var.",
      "Vietnamese": "Tôi cần giúp đỡ.",
      "Indonesian": "Saya butuh bantuan.",
      "Dutch": "Ik heb hulp nodig."
    },
  ),
  const SurvivalPhrase(
    english: "Call the police.",
    phonetic: "kawl the puh-LEES",
    translations: {
      "English": "Call the police.",
      "French": "Appelez la police.",
      "Spanish": "Llame a la policía.",
      "Hindi": "पुलिस को बुलाओ।",
      "German": "Rufen Sie die Polizei.",
      "Italian": "Chiama la polizia.",
      "Chinese": "叫警察。",
      "Japanese": "警察を呼んでください。",
      "Korean": "경찰을 불러주세요.",
      "Russian": "Вызовите полицию.",
      "Turkish": "Polisi arayın.",
      "Vietnamese": "Gọi cảnh sát.",
      "Indonesian": "Hubungi polisi.",
      "Dutch": "Bel de politie."
    },
  ),
  const SurvivalPhrase(
    english: "I lost my passport.",
    phonetic: "ai lost mai PAS-pawrt",
    translations: {
      "English": "I lost my passport.",
      "French": "J'ai perdu mon passeport.",
      "Spanish": "Perdí mi pasaporte.",
      "Hindi": "मेरा पासपोर्ट खो गया है।",
      "German": "Ich habe meinen Reisepass verloren.",
      "Italian": "Ho perso il mio passaporto.",
      "Chinese": "我丢了护照。",
      "Japanese": "パスポートを紛失しました。",
      "Korean": "여권을 잃어버렸어요.",
      "Russian": "Я потерял свой паспорт.",
      "Turkish": "Pasaportumu kaybettim.",
      "Vietnamese": "Tôi bị mất hộ chiếu.",
      "Indonesian": "Paspor saya hilang.",
      "Dutch": "Ik ben mijn paspoort kwijt."
    },
  ),
  const SurvivalPhrase(
    english: "I need a lawyer.",
    phonetic: "ai need a LOY-er",
    translations: {
      "English": "I need a lawyer.",
      "French": "J'ai besoin d'un avocat.",
      "Spanish": "Necesito un abogado.",
      "Hindi": "मुझे एक वकील की जरूरत है।",
      "German": "Ich brauche einen Anwalt.",
      "Italian": "Ho bisogno di un avvocato.",
      "Chinese": "我需要律师。",
      "Japanese": "弁護士が必要です。",
      "Korean": "변호사가 필요해요.",
      "Russian": "Мне нужен адвокат.",
      "Turkish": "Bir avukata ihtiyacım var.",
      "Vietnamese": "Tôi cần luật sư.",
      "Indonesian": "Saya butuh pengacara.",
      "Dutch": "Ik heb een advocaat nodig."
    },
  ),
  const SurvivalPhrase(
    english: "I need to contact my embassy.",
    phonetic: "ai need too KON-takt mai EM-buh-see",
    translations: {
      "English": "I need to contact my embassy.",
      "French": "Je dois contacter mon ambassade.",
      "Spanish": "Necesito contactar a mi embajada.",
      "Hindi": "मुझे अपने दूतावास से संपर्क करना है।",
      "German": "Ich muss meine Botschaft kontaktieren.",
      "Italian": "Devo contattare la mia ambasciata.",
      "Chinese": "我需要联系我的大使馆。",
      "Japanese": "大使館に連絡する必要があります。",
      "Korean": "대사관에 연락해야 해요.",
      "Russian": "Мне нужно связаться с моим посольством.",
      "Turkish": "Büyükelçiliğimle iletişime geçmem gerekiyor.",
      "Vietnamese": "Tôi cần liên hệ với đại sứ quán của tôi.",
      "Indonesian": "Saya harus menghubungi kedutaan saya.",
      "Dutch": "Ik moet contact opnemen met mijn ambassade."
    },
  ),
  const SurvivalPhrase(
    english: "Someone stole my bag.",
    phonetic: "SUM-wun stohl mai bag",
    translations: {
      "English": "Someone stole my bag.",
      "French": "Quelqu'un a volé mon sac.",
      "Spanish": "Alguien robó mi bolsa.",
      "Hindi": "किसी ने मेरा बैग चुरा लिया।",
      "German": "Jemand hat meine Tasche gestohlen.",
      "Italian": "Qualcuno ha rubato la mia borsa.",
      "Chinese": "有人偷了我的包。",
      "Japanese": "誰かにバッグを盗まれました。",
      "Korean": "누군가 제 가방을 훔쳐갔어요.",
      "Russian": "Кто-то украл мою сумку.",
      "Turkish": "Biri çantamı çaldı.",
      "Vietnamese": "Ai đó đã đánh cắp túi của tôi.",
      "Indonesian": "Seseorang mencuri tas saya.",
      "Dutch": "Iemand heeft mijn tas gestolen."
    },
  ),
  const SurvivalPhrase(
    english: "I do not understand.",
    phonetic: "ai doo not un-der-STAND",
    translations: {
      "English": "I do not understand.",
      "French": "Je ne comprends pas.",
      "Spanish": "No entiendo.",
      "Hindi": "मुझे समझ नहीं आ रहा है।",
      "German": "Ich verstehe nicht.",
      "Italian": "Non capisco.",
      "Chinese": "我不明白。",
      "Japanese": "理解できません。",
      "Korean": "이해가 안 돼요.",
      "Russian": "Я не понимаю.",
      "Turkish": "Anlamıyorum.",
      "Vietnamese": "Tôi không hiểu.",
      "Indonesian": "Saya tidak mengerti.",
      "Dutch": "Ik begrijp het niet."
    },
  ),
  const SurvivalPhrase(
    english: "Please write it down.",
    phonetic: "pleez ryt it down",
    translations: {
      "English": "Please write it down.",
      "French": "S'il vous plaît, écrivez-le.",
      "Spanish": "Por favor, escríbalo.",
      "Hindi": "कृपया इसे लिख दीजिए।",
      "German": "Bitte schreiben Sie es auf.",
      "Italian": "Per favore, lo scriva.",
      "Chinese": "请写下来。",
      "Japanese": "書いてください。",
      "Korean": "적어주세요.",
      "Russian": "Запишите это, пожалуйста.",
      "Turkish": "Lütfen bunu yazın.",
      "Vietnamese": "Vui lòng viết ra.",
      "Indonesian": "Tolong tuliskan.",
      "Dutch": "Schrijf het alstublieft op."
    },
  ),
  const SurvivalPhrase(
    english: "Where is the police station?",
    phonetic: "wair iz the puh-LEES STAY-shuhn",
    translations: {
      "English": "Where is the police station?",
      "French": "Où est le commissariat de police?",
      "Spanish": "¿Dónde está la comisaría de policía?",
      "Hindi": "पुलिस स्टेशन कहाँ है?",
      "German": "Wo ist die Polizeidienststelle?",
      "Italian": "Dov'è la stazione di polizia?",
      "Chinese": "警察局在哪里？",
      "Japanese": "警察署はどこですか？",
      "Korean": "경찰서가 어디에 있나요?",
      "Russian": "Где полицейский участок?",
      "Turkish": "Polis karakolu nerede?",
      "Vietnamese": "Đồn cảnh sát ở đâu?",
      "Indonesian": "Di mana kantor polisi?",
      "Dutch": "Waar is het politiebureau?"
    },
  ),
  const SurvivalPhrase(
    english: "I cannot find my hotel.",
    phonetic: "ai KAN-not fynd mai hoh-TEL",
    translations: {
      "English": "I cannot find my hotel.",
      "French": "Je ne trouve pas mon hôtel.",
      "Spanish": "No puedo encontrar mi hotel.",
      "Hindi": "मुझे अपना होटल नहीं मिल रहा है।",
      "German": "Ich kann mein Hotel nicht finden.",
      "Italian": "Non riesco a trovare il mio hotel.",
      "Chinese": "我找不到我的酒店。",
      "Japanese": "ホテルが見つかりません。",
      "Korean": "제 호텔을 못 찾겠어요.",
      "Russian": "Я не могу найти свой отель.",
      "Turkish": "Otelimi bulamıyorum.",
      "Vietnamese": "Tôi không tìm thấy khách sạn của mình.",
      "Indonesian": "Saya tidak bisa menemukan hotel saya.",
      "Dutch": "Ik kan mijn hotel niet vinden."
    },
  ),
];

class SurvivalPacksScreen extends StatefulWidget {
  final String currentLanguage;
  const SurvivalPacksScreen({super.key, required this.currentLanguage});

  @override
  State<SurvivalPacksScreen> createState() => _SurvivalPacksScreenState();
}

class _SurvivalPacksScreenState extends State<SurvivalPacksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AccessibilityConfig>(
      valueListenable: accessibilityNotifier,
      builder: (context, accessConfig, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: getDyslexiaBackgroundColor(context),
          appBar: AppBar(
            title: const Text("Survival Vocabulary Packs"),
            backgroundColor: isDark ? const Color(0xFF1E1E32) : const Color(0xFF4A5CF0),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.tealAccent,
              tabs: const [
                Tab(icon: Icon(Icons.medical_services_rounded), text: "Healthcare"),
                Tab(icon: Icon(Icons.directions_bus_rounded), text: "Transport"),
                Tab(icon: Icon(Icons.gavel_rounded), text: "Legal/Safety"),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildPhraseList(healthcarePhrases, isDark, accessConfig),
              _buildPhraseList(transportPhrases, isDark, accessConfig),
              _buildPhraseList(legalPhrases, isDark, accessConfig),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhraseList(
      List<SurvivalPhrase> phrases, bool isDark, AccessibilityConfig accessConfig) {
    return ListView.builder(
      padding: EdgeInsets.all(accessConfig.useDyslexiaFont ? 20 : 16),
      itemCount: phrases.length,
      itemBuilder: (context, index) {
        final phrase = phrases[index];
        final translation =
            phrase.translations[widget.currentLanguage] ?? phrase.english;

        return Container(
          margin: EdgeInsets.only(bottom: accessConfig.useDyslexiaFont ? 20 : 16),
          decoration: getDyslexiaCardDecoration(context),
          child: Padding(
            padding: EdgeInsets.all(accessConfig.useDyslexiaFont ? 20.0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── English Text ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: DyslexicText(
                        phrase.english,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up, color: Colors.teal),
                      onPressed: () => speak(phrase.english, "English"),
                    )
                  ],
                ),

                // Phonetic Guide
                if (accessConfig.showPhonetics)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      "Pronounce: [ ${phrase.phonetic} ]",
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color:
                            isDark ? Colors.cyanAccent : Colors.teal.shade800,
                      ),
                    ),
                  ),

                const Divider(height: 24, thickness: 1),

                // ── Translation ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${widget.currentLanguage} translation",
                            style: TextStyle(
                                fontSize: 11,
                                color:
                                    isDark ? Colors.white38 : Colors.black38),
                          ),
                          const SizedBox(height: 4),
                          DyslexicText(
                            translation,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.tealAccent
                                  : Colors.teal.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        // Speak Translation
                        IconButton(
                          icon: const Icon(Icons.volume_up,
                              color: Colors.indigo),
                          onPressed: () =>
                              speak(translation, widget.currentLanguage),
                        ),
                        // Sign language bridge
                        IconButton(
                          icon: const Icon(Icons.accessibility_new_rounded,
                              color: Colors.teal),
                          tooltip: "Fingerspell this word",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SignLanguageScreen(
                                    initialWord: translation),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
