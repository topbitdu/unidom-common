# Unidom Common Roadmap 常用领域模型引擎路线图

## v0.1
1. Enable PostgreSQL UUID Extension migration (20000101000000)

## v0.2
1. Model Extension concern
2. Data Helper module

## v0.3
1. Improve the Data Helper module
2. Improve the Model Extension concern
3. Improve the Common module to add the NULL_UUID constant as: ``00000000-0000-0000-0000-000000000000``
4. Improve the Common module to add the SELF constant as: ``~``

## v0.4
1. Improve the Model Extension to add the .``to_id`` method

## v0.5
1. Supported the No-SQL columns in the Model Extension

## v0.5.1
1. Fixed the issue of No-SQL columns reader methods

## v0.6
1. Improve the Model Extension concern to generate the {acted}_before, {acted}_not_after, {acted}_after, and {acted}_not_before scopes for the {acted}_at date time field automatically
2. Improve the Model Extension concern to add the #notation_column_where scope

## v0.7
1. Improve the Model Extension concern to generate the {action}_transited_to scope for the #{action}_state field automatically

## v0.8
1. Improved the Model Extension concern to add the .``notation_boolean_column`` method

## v0.9
1. Improve the Model Extension concern to add the ::notation_boolean_column_where scope

## v1.0
1. Improve the Model Extension concern to check the column type
2. Improve the Model Extension concern to support the Keyword Arguments

## v1.0.1
1. Improve the Ruby Gem Specification to support Rails v5.0

## v1.1
1. Numeration class
2. AES 256 Cryptor concern
3. SHA 512 Digester concern

## v1.2
1. MD 5 Digester concern
2. SHA 256 Digester concern
3. SHA 384 Digester concern

## v1.3
1. SHA 1 Digester concern
2. SHA 2 Digester concern
3. Improve the Model Extension to generate the validations for the #{action}_state field automatically
4. Improve the AES 256 Cryptor concern for the class methods

## v1.4
1. Improve the Model Extension concern to add the #``assert_present!`` & the .``assert_present!`` method

## v1.5
1. Improve the Model Extension concern to support the Exact Column specification

## v1.6
1. Secure Column concern
2. Exact Column concern
3. Argument Validation concern
4. Notation Column concern
5. Improve the Model Extension concern to include the Argument Validation concern, the Exact Column concern, the Notation Column concern, & the Secure Column concern

## v1.7
1. Improve the Model Extension concern to support the Progne Tapera enum for the code fields
2. Improve the Secure Column concern to add the encryption algorithm
3. YAML helper module

## v1.7.1
1. Improve the Secure Column concern for the .``exact_signature`` method
2. Improve the Ruby Gem Specification to depend on [progne_tapera](https://github.com/topbitdu/progne_tapera) v0.4

## v1.7.2
1. Improve the Secure Column concern for the un-selected secure columns

## v1.8
1. Engine Extension concern

## v1.8.1
1. Improve the Model Extension concern for the validations for the #ordinal attribute, the #grade attribute, & the #priority attribute

## v1.9
1. Neglection class
2. Improve the Model Extension concern to integrate the Neglection class
