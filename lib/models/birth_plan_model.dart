/// Aura Pregnancy - Kişisel Doğum Planı ve Tercihleri Modeli
class BirthPlanModel {
  final bool dimLights;
  final bool ambientMusic;
  final bool aromatherapy;
  final bool quietEnvironment;

  final bool epiduralPreferred;
  final bool naturalPainRelief;
  final bool birthingBall;
  final bool warmWaterShower;

  final bool delayedCordClamping;
  final bool partnerCutsCord;
  final bool immediateSkinToSkin;
  final bool delayNewbornBath24h;

  final bool discussBeforeIntervention;
  final bool spontaneousPushing;

  final String specialWishes;
  final String pediatricianName;
  final String emergencyContact;

  const BirthPlanModel({
    this.dimLights = true,
    this.ambientMusic = true,
    this.aromatherapy = false,
    this.quietEnvironment = true,
    this.epiduralPreferred = false,
    this.naturalPainRelief = true,
    this.birthingBall = true,
    this.warmWaterShower = true,
    this.delayedCordClamping = true,
    this.partnerCutsCord = true,
    this.immediateSkinToSkin = true,
    this.delayNewbornBath24h = true,
    this.discussBeforeIntervention = true,
    this.spontaneousPushing = true,
    this.specialWishes = '',
    this.pediatricianName = '',
    this.emergencyContact = '',
  });

  BirthPlanModel copyWith({
    bool? dimLights,
    bool? ambientMusic,
    bool? aromatherapy,
    bool? quietEnvironment,
    bool? epiduralPreferred,
    bool? naturalPainRelief,
    bool? birthingBall,
    bool? warmWaterShower,
    bool? delayedCordClamping,
    bool? partnerCutsCord,
    bool? immediateSkinToSkin,
    bool? delayNewbornBath24h,
    bool? discussBeforeIntervention,
    bool? spontaneousPushing,
    String? specialWishes,
    String? pediatricianName,
    String? emergencyContact,
  }) {
    return BirthPlanModel(
      dimLights: dimLights ?? this.dimLights,
      ambientMusic: ambientMusic ?? this.ambientMusic,
      aromatherapy: aromatherapy ?? this.aromatherapy,
      quietEnvironment: quietEnvironment ?? this.quietEnvironment,
      epiduralPreferred: epiduralPreferred ?? this.epiduralPreferred,
      naturalPainRelief: naturalPainRelief ?? this.naturalPainRelief,
      birthingBall: birthingBall ?? this.birthingBall,
      warmWaterShower: warmWaterShower ?? this.warmWaterShower,
      delayedCordClamping: delayedCordClamping ?? this.delayedCordClamping,
      partnerCutsCord: partnerCutsCord ?? this.partnerCutsCord,
      immediateSkinToSkin: immediateSkinToSkin ?? this.immediateSkinToSkin,
      delayNewbornBath24h: delayNewbornBath24h ?? this.delayNewbornBath24h,
      discussBeforeIntervention: discussBeforeIntervention ?? this.discussBeforeIntervention,
      spontaneousPushing: spontaneousPushing ?? this.spontaneousPushing,
      specialWishes: specialWishes ?? this.specialWishes,
      pediatricianName: pediatricianName ?? this.pediatricianName,
      emergencyContact: emergencyContact ?? this.emergencyContact,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dim_lights': dimLights ? 1 : 0,
      'ambient_music': ambientMusic ? 1 : 0,
      'aromatherapy': aromatherapy ? 1 : 0,
      'quiet_environment': quietEnvironment ? 1 : 0,
      'epidural_preferred': epiduralPreferred ? 1 : 0,
      'natural_pain_relief': naturalPainRelief ? 1 : 0,
      'birthing_ball': birthingBall ? 1 : 0,
      'warm_water_shower': warmWaterShower ? 1 : 0,
      'delayed_cord_clamping': delayedCordClamping ? 1 : 0,
      'partner_cuts_cord': partnerCutsCord ? 1 : 0,
      'immediate_skin_to_skin': immediateSkinToSkin ? 1 : 0,
      'delay_newborn_bath_24h': delayNewbornBath24h ? 1 : 0,
      'discuss_before_intervention': discussBeforeIntervention ? 1 : 0,
      'spontaneous_pushing': spontaneousPushing ? 1 : 0,
      'special_wishes': specialWishes,
      'pediatrician_name': pediatricianName,
      'emergency_contact': emergencyContact,
    };
  }

  factory BirthPlanModel.fromMap(Map<String, dynamic> map) {
    return BirthPlanModel(
      dimLights: (map['dim_lights'] as int? ?? 1) == 1,
      ambientMusic: (map['ambient_music'] as int? ?? 1) == 1,
      aromatherapy: (map['aromatherapy'] as int? ?? 0) == 1,
      quietEnvironment: (map['quiet_environment'] as int? ?? 1) == 1,
      epiduralPreferred: (map['epidural_preferred'] as int? ?? 0) == 1,
      naturalPainRelief: (map['natural_pain_relief'] as int? ?? 1) == 1,
      birthingBall: (map['birthing_ball'] as int? ?? 1) == 1,
      warmWaterShower: (map['warm_water_shower'] as int? ?? 1) == 1,
      delayedCordClamping: (map['delayed_cord_clamping'] as int? ?? 1) == 1,
      partnerCutsCord: (map['partner_cuts_cord'] as int? ?? 1) == 1,
      immediateSkinToSkin: (map['immediate_skin_to_skin'] as int? ?? 1) == 1,
      delayNewbornBath24h: (map['delay_newborn_bath_24h'] as int? ?? 1) == 1,
      discussBeforeIntervention: (map['discuss_before_intervention'] as int? ?? 1) == 1,
      spontaneousPushing: (map['spontaneous_pushing'] as int? ?? 1) == 1,
      specialWishes: map['special_wishes'] as String? ?? '',
      pediatricianName: map['pediatrician_name'] as String? ?? '',
      emergencyContact: map['emergency_contact'] as String? ?? '',
    );
  }
}
