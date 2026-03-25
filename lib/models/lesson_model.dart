import 'package:flutter/material.dart';

/// Shared lesson data model used by [LessonList] and [LessonDetailScreen].
class LessonModel {
  final String emoji;
  final Color iconBg;
  final String title;
  final String meta;
  final bool locked;

  // Rich lesson content shown in LessonDetailScreen
  final String description;
  final List<LessonSection> sections;
  final List<String> keyFacts;

  const LessonModel({
    required this.emoji,
    required this.iconBg,
    required this.title,
    required this.meta,
    this.locked = false,
    required this.description,
    required this.sections,
    required this.keyFacts,
  });
}

class LessonSection {
  final String heading;
  final String body;
  final String? emoji;

  const LessonSection({
    required this.heading,
    required this.body,
    this.emoji,
  });
}

/// Canonical lesson catalogue — single source of truth.
const lessons = [
  LessonModel(
    emoji: '🌎',
    iconBg: Color(0xFFE1F5EE),
    title: 'Formation of Earth',
    meta: '8 min · Intro',
    description:
        'Earth formed around 4.5 billion years ago from a swirling cloud of gas and dust called a solar nebula. '
        'Gravity caused this material to collapse, heat up, and eventually coalesce into the rocky world we call home.',
    sections: [
      LessonSection(
        emoji: '☁️',
        heading: 'The Solar Nebula',
        body:
            'A giant cloud of hydrogen, helium, and heavier elements began to contract under its own gravity roughly 4.6 billion years ago. '
            'As it spun faster, a young Sun ignited at the center while the remaining disc of material slowly clumped together.',
      ),
      LessonSection(
        emoji: '🔴',
        heading: 'The Molten Stage',
        body:
            'Intense heat from radioactive decay and constant asteroid bombardment kept early Earth completely molten. '
            'Heavier iron and nickel sank to form the core while lighter silicates rose to become the mantle and crust.',
      ),
      LessonSection(
        emoji: '🌊',
        heading: 'Oceans & Atmosphere',
        body:
            'As Earth cooled over hundreds of millions of years, water vapor condensed into vast oceans. '
            'Volcanic outgassing and comet impacts also delivered water and organic molecules — key ingredients for life.',
      ),
      LessonSection(
        emoji: '🧬',
        heading: 'First Signs of Life',
        body:
            'Evidence of microbial life appears in rocks as old as 3.7 billion years. '
            'These early organisms would eventually transform the atmosphere, paving the way for complex life.',
      ),
    ],
    keyFacts: [
      'Age: ~4.54 billion years',
      'Distance from Sun: 149.6 million km',
      'Time to form solid crust: ~500 million years',
      'Moon formed from a giant impact ~4.5 Ga',
    ],
  ),
  LessonModel(
    emoji: '🔥',
    iconBg: Color(0xFFFAEEDA),
    title: 'Volcanic Eruptions',
    meta: '12 min · Geology',
    description:
        'Volcanoes are one of Earth\'s most powerful geological forces. '
        'They build mountains, enrich soils, and have dramatically shaped our planet\'s climate throughout history.',
    sections: [
      LessonSection(
        emoji: '🌋',
        heading: 'How Volcanoes Form',
        body:
            'Volcanoes occur where tectonic plates diverge or converge, and at "hot spots" above mantle plumes. '
            'Molten rock (magma) rises through fissures, erupting as lava, ash, and gas at the surface.',
      ),
      LessonSection(
        emoji: '💨',
        heading: 'Types of Eruptions',
        body:
            'Eruption style depends on magma viscosity and gas content. '
            'Low-viscosity basaltic lava flows gently (Hawaiian type), while high-silica magma explodes violently (Plinian type), '
            'sending ash columns 40+ km into the stratosphere.',
      ),
      LessonSection(
        emoji: '🌍',
        heading: 'Climate Impact',
        body:
            'Large eruptions inject sulfur dioxide into the stratosphere, forming aerosols that reflect sunlight '
            'and cause global cooling. The 1991 Pinatubo eruption lowered global temperatures by ~0.5 °C for a year.',
      ),
    ],
    keyFacts: [
      '~1,500 potentially active volcanoes worldwide',
      'Largest known: Mauna Loa, Hawaii (9 km tall from seafloor)',
      'Fastest lava flow recorded: ~60 km/h',
      '80% of Earth\'s surface is volcanic in origin',
    ],
  ),
  LessonModel(
    emoji: '🌊',
    iconBg: Color(0xFFE3F0FF),
    title: 'Ocean Currents',
    meta: '10 min · Oceans',
    description:
        'Ocean currents are continuous, directed movements of seawater driven by wind, temperature, salinity, '
        'and Earth\'s rotation. They act as a global conveyor belt, redistributing heat and regulating climate.',
    sections: [
      LessonSection(
        emoji: '🌬️',
        heading: 'Surface Currents',
        body:
            'Wind drags the top 100–200 m of ocean into motion. The Coriolis effect deflects these flows '
            'into large rotating gyres — clockwise in the Northern Hemisphere, counter-clockwise in the Southern.',
      ),
      LessonSection(
        emoji: '🧊',
        heading: 'Thermohaline Circulation',
        body:
            'Deep ocean circulation is driven by differences in temperature (thermo) and salinity (haline). '
            'Cold, salty water near the poles sinks and flows along the seafloor, completing a 1,000-year circuit '
            'around all major ocean basins.',
      ),
      LessonSection(
        emoji: '🌡️',
        heading: 'Climate Regulation',
        body:
            'The Gulf Stream transports warm tropical water to northwest Europe, keeping temperatures there '
            '5–10°C warmer than equivalent latitudes elsewhere. Disrupting this current could trigger dramatic regional cooling.',
      ),
    ],
    keyFacts: [
      'Gulf Stream speed: up to 9 km/h',
      'Thermohaline cycle takes ~1,000 years to complete',
      'Oceans absorb ~93% of excess heat from climate change',
      'El Niño alters currents every 2–7 years',
    ],
  ),
  LessonModel(
    emoji: '🌬️',
    iconBg: Color(0xFFEAF3DE),
    title: 'Jet Streams',
    meta: '9 min · Atmosphere',
    description:
        'Jet streams are fast-flowing, narrow air currents found in the upper troposphere. '
        'They steer weather systems, influence flight paths, and are increasingly affected by climate change.',
    sections: [
      LessonSection(
        emoji: '✈️',
        heading: 'What Are Jet Streams?',
        body:
            'Jet streams form at the boundary between cold polar air and warm tropical air. '
            'They blow from west to east at 9–12 km altitude and can reach speeds of 400 km/h. '
            'There are two main jets per hemisphere: the polar and subtropical jet streams.',
      ),
      LessonSection(
        emoji: '🌪️',
        heading: 'Steering Weather',
        body:
            'Low-pressure storm systems are steered by the polar jet stream. '
            'When the jet dips south, cold Arctic air floods mid-latitudes. '
            'When it surges north, warm air penetrates the Arctic — a pattern linked to extreme weather events.',
      ),
      LessonSection(
        emoji: '📈',
        heading: 'Climate Change Link',
        body:
            'Rapid Arctic warming is shrinking the temperature gradient that powers the jet stream, '
            'causing it to meander more widely. This "waviness" is associated with prolonged heatwaves, '
            'droughts, and cold snaps across the Northern Hemisphere.',
      ),
    ],
    keyFacts: [
      'Top speed recorded: ~407 km/h',
      'Altitude: ~9,000–12,000 m',
      'Discovered by World War II pilots',
      'Save ~1 hour on transatlantic eastbound flights',
    ],
  ),
];
