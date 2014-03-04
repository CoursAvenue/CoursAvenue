# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
CoursAvenue::Application.config.secret_key      = ENV['SECRET_KEY']      || '428a6a719542ea25bd1a82c56a722f0909fec4e47cbb6a2f08a2fe926fdf23da35f18edebe9933adadd9b5e96f40d988956751a8d52c018ae5a839ff40d7ce39'
CoursAvenue::Application.config.secret_key_base = ENV['SECRET_KEY_BASE'] || '519a7650a34d1a85f19261aff764166654e789f07a2305cbe849ef1402a8a5e9324a5b57ab9947dfb0350e0c314cfc7dfc2ee99cfc162300cc3997a58958ce6e'
