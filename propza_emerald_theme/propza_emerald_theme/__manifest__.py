# -*- coding: utf-8 -*-
{
    'name': 'Propza Emerald Green Theme',
    'version': '17.0.1.0.0',
    'summary': 'Emerald Green color theme for Odoo 17 backend',
    'description': """
        Replaces the default Odoo 17 backend color scheme with
        Propza's Emerald Green palette across the entire system.
        No model changes — pure UI override.
    """,
    'author': 'Khatwa Tech / AE',
    'website': 'https://ae.hdrelhaj.com',
    'category': 'Theme/Backend',
    'license': 'LGPL-3',
    'depends': ['web'],
    'data': [],
    'assets': {
        # ── Backend (main Odoo interface) ──────────────────────
        'web.assets_backend': [
            'propza_emerald_theme/static/src/scss/variables.scss',
            'propza_emerald_theme/static/src/scss/navbar.scss',
            'propza_emerald_theme/static/src/scss/buttons.scss',
            'propza_emerald_theme/static/src/scss/form.scss',
            'propza_emerald_theme/static/src/scss/list.scss',
            'propza_emerald_theme/static/src/scss/kanban.scss',
            'propza_emerald_theme/static/src/scss/misc.scss',
        ],
    },
    'installable': True,
    'auto_install': False,
    'application': False,
}
