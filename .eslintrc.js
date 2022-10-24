module.exports = {
    'env': {
        'browser': true,
        'es2021': true
    },
    'extends': [
        'eslint:recommended',
        'plugin:prettier/recommended',
    ],
    'overrides': [
    ],
    'parserOptions': {
        'ecmaVersion': 'latest'
    },
    plugins: ['prettier'],
    'rules': {
        'indent': [
            'error',
            4
        ],
        'linebreak-style': [
            'error',
            'unix'
        ],
        'quotes': [
            'error',
            'single'
        ],
        'semi': [
            'error',
            'always'
        ]
    },
    'rules': {
        'prettier/prettier': ['warn'],
        'no-undef': 'off'
    }
};
