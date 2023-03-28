import 'dart:math';

enum Race {
  Unknown, // Used when race is not relevant (i.e., Squad)
  Amazon,
  BlackOrc,
  Bretonnian,
  ChaosChosen,
  ChaosDwarf,
  ChaosRenegade,
  DarkElf,
  Dwarf,
  ElfUnion,
  Goblin,
  Halfling,
  HighElf,
  Human,
  ImperialNobility,
  Khorne,
  Lizardmen,
  NecromanticHorror,
  Norse,
  Nurgle,
  Ogre,
  OldWorldAlliance,
  Orc,
  ShamblingUndead,
  Skaven,
  Slann,
  Snotling,
  TombKings,
  UnderworldDenizens,
  Vampire,
  WoodElf,
}

class RaceUtils {
  static final String _baseLogoFolder = "assets/images/teams/";

  static final Map<Race, String> _raceToLogo = {
    Race.Unknown: _baseLogoFolder + "unknown.png",
    Race.Amazon: _baseLogoFolder + "logo_amazon.png",
    Race.BlackOrc: _baseLogoFolder + "logo_blackorcs.png",
    Race.Bretonnian: _baseLogoFolder + "logo_bretonnians.png",
    Race.ChaosChosen: _baseLogoFolder + "logo_chaos.png",
    Race.ChaosDwarf: _baseLogoFolder + "logo_chaosdwarf.png",
    Race.ChaosRenegade: _baseLogoFolder + "logo_chaosrenegades.png",
    Race.DarkElf: _baseLogoFolder + "logo_darkelf.png",
    Race.Dwarf: _baseLogoFolder + "logo_dwarf.png",
    Race.ElfUnion: _baseLogoFolder + "logo_elvenunion.png",
    Race.Goblin: _baseLogoFolder + "logo_goblins.png",
    Race.Halfling: _baseLogoFolder + "logo_halflings.png",
    Race.HighElf: _baseLogoFolder + "logo_highelf.png",
    Race.Human: _baseLogoFolder + "logo_human.png",
    Race.ImperialNobility: _baseLogoFolder + "logo_imperialnobility.png",
    Race.Khorne: _baseLogoFolder + "logo_khorne.png",
    Race.Lizardmen: _baseLogoFolder + "logo_lizardmen.png",
    Race.NecromanticHorror: _baseLogoFolder + "logo_necromantic.png",
    Race.Norse: _baseLogoFolder + "logo_norse.png",
    Race.Nurgle: _baseLogoFolder + "logo_nurgle.png",
    Race.Ogre: _baseLogoFolder + "logo_ogre.png",
    Race.OldWorldAlliance: _baseLogoFolder + "logo_oldworldalliance.png",
    Race.Orc: _baseLogoFolder + "logo_orc.png",
    Race.ShamblingUndead: _baseLogoFolder + "logo_shamblingundead.png",
    Race.Skaven: _baseLogoFolder + "logo_skaven.png",
    Race.Slann: _baseLogoFolder + "logo_slann.png",
    Race.Snotling: _baseLogoFolder + "logo_snotling.png",
    Race.TombKings: _baseLogoFolder + "logo_tombkings.png",
    Race.UnderworldDenizens: _baseLogoFolder + "logo_underworld.png",
    Race.Vampire: _baseLogoFolder + "logo_vampire.png",
    Race.WoodElf: _baseLogoFolder + "logo_woodelf.png",
  };

  static final Map<Race, String> _raceToName = {
    Race.Unknown: "", // empty string for unknown
    Race.Amazon: "Amazon",
    Race.BlackOrc: "Black Orc",
    Race.Bretonnian: "Bretonnian",
    Race.ChaosChosen: "Chaos Chosen",
    Race.ChaosDwarf: "Chaos Dwarf",
    Race.ChaosRenegade: "Chaos Renegade",
    Race.DarkElf: "Dark Elf",
    Race.Dwarf: "Dwarf",
    Race.ElfUnion: "Elf Union",
    Race.Goblin: "Goblin",
    Race.Halfling: "Halfling",
    Race.HighElf: "High Elf",
    Race.Human: "Human",
    Race.ImperialNobility: "Imperial Nobility",
    Race.Khorne: "Khorne",
    Race.Lizardmen: "Lizardmen",
    Race.NecromanticHorror: "Necromantic Horror",
    Race.Norse: "Norse",
    Race.Nurgle: "Nurgle",
    Race.Ogre: "Ogre",
    Race.OldWorldAlliance: "Old World Alliance",
    Race.Orc: "Orc",
    Race.ShamblingUndead: "Shambling Undead",
    Race.Skaven: "Skaven",
    Race.Slann: "Slann",
    Race.Snotling: "Snotling",
    Race.TombKings: "Tomb Kings",
    Race.UnderworldDenizens: "Underworld Denizens",
    Race.Vampire: "Vampire",
    Race.WoodElf: "Wood Elf",
  };

  static final Map<String, Race> _nameToRace =
      _raceToName.map((key, value) => MapEntry(value, key));

  static String getLogo(Race race) {
    String? logo = _raceToLogo[race];
    return logo != null ? logo : "";
  }

  static String getName(Race race) {
    String? name = _raceToName[race];
    return name != null ? name : "";
  }

  static Race getRace(String name) {
    Race? race = _nameToRace[name];
    return race != null ? race : Race.Unknown;
  }

  static Race randomRace(Random rnd) {
    // Force skip 0 (which is Unknown)
    int idx = rnd.nextInt(Race.values.length - 2) + 1;
    return Race.values[idx];
  }

  static bool isStunty(Race race) {
    return race == Race.Ogre ||
        race == Race.Halfling ||
        race == Race.Goblin ||
        race == Race.Snotling;
  }
}
