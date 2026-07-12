export const initialApps = [
  {
    id: '1',
    name: 'AeroPlayer Pro',
    packageName: 'com.aero.player.pro',
    description: 'A next-generation media player featuring hardware acceleration, subtitle synchronization, and support for all major video and audio formats. Designed with a sleek glassmorphic UI and optimized for low battery consumption.',
    icon: 'Play', // Lucide icon name
    category: 'Media & Video',
    downloads: '124.5K',
    rating: '4.8',
    activeUsers: '89.2K',
    screenshots: [
      'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
      'linear-gradient(135deg, #2af598 0%, #009efd 100%)',
      'linear-gradient(135deg, #ff9a9e 0%, #fecfef 100%)'
    ],
    releases: [
      {
        version: '2.4.1',
        buildNumber: 42,
        releaseNotes: 'Fixed a crash on Android 13 when loading external subtitles. Improved audio synchronization for Bluetooth headphones. Updated translation files.',
        date: '2026-07-10',
        size: '18.4 MB',
        apkUrl: '#'
      },
      {
        version: '2.4.0',
        buildNumber: 41,
        releaseNotes: 'Added support for picture-in-picture mode. Introduced new equalizer presets. Performance optimizations for 4K video playback.',
        date: '2026-06-28',
        size: '18.2 MB',
        apkUrl: '#'
      },
      {
        version: '2.3.5',
        buildNumber: 39,
        releaseNotes: 'Minor bug fixes and UI polish. Fixed memory leak in background audio playback.',
        date: '2026-05-15',
        size: '17.9 MB',
        apkUrl: '#'
      }
    ],
    members: [
      { email: 'owner@aeroplayer.com', role: 'Owner' },
      { email: 'dev1@aeroplayer.com', role: 'Developer' },
      { email: 'tester1@aeroplayer.com', role: 'Tester' }
    ]
  },
  {
    id: '2',
    name: 'TaskFlow Planner',
    packageName: 'com.taskflow.planner',
    description: 'A minimalist task manager and planner that helps you organize your daily life. Syncs across all devices, supports markdown notes, and features smart reminders.',
    icon: 'CheckSquare',
    category: 'Productivity',
    downloads: '45.2K',
    rating: '4.6',
    activeUsers: '28.1K',
    screenshots: [
      'linear-gradient(135deg, #f6d365 0%, #fda085 100%)',
      'linear-gradient(135deg, #a1c4fd 0%, #c2e9fb 100%)'
    ],
    releases: [
      {
        version: '1.2.0',
        buildNumber: 15,
        releaseNotes: 'Added dark mode support. Implemented recurring tasks. Fixed sync issues on slow networks.',
        date: '2026-07-01',
        size: '12.1 MB',
        apkUrl: '#'
      },
      {
        version: '1.1.0',
        buildNumber: 12,
        releaseNotes: 'Initial public beta release. Basic task creation and category organization.',
        date: '2026-06-10',
        size: '11.8 MB',
        apkUrl: '#'
      }
    ],
    members: [
      { email: 'creator@taskflow.io', role: 'Owner' }
    ]
  }
];
