# Unidom Common Change Log 常用领域模型引擎变更日志

## v0.1
1. Enable PostgreSQL UUID Extension

## v0.2
1. Model Extension concern
2. Data Helper module

## v0.3
1. Improved the Data Helper module
2. Improved the Model Extension concern
3. Added the Unidom::Common::NULL_UUID constant
4. Added the Unidom::Common::SELF constant

## v0.4
1. Added the ::to_id class methods in the Model Extension

## v0.5
1. Supported the No-SQL columns in the Model Extension

## v0.5.1
1. Fixed the issue of No-SQL columns reader methods

## v0.6
1. Improved the Model Extension concern to generate the {acted}_before, {acted}_not_after, {acted}_after, and {acted}_not_before scopes for the {acted}_at date time field automatically
2. Improved the Model Extension concern to add the #notation_column_where scope

## v0.7
1. Improved the Model Extension concern to generate the {action}_transited_to scope for the #{action}_state field automatically

## v0.8
1. Improved the Model Extension concern to add the ::notation_boolean_column method

## v0.9
1. Improved the Model Extension concern to add the ::notation_boolean_column_where scope

## v1.0
1. Improved the Model Extension concern to check the column type
2. Improved the Model Extension concern to support the Keyword Arguments

## v1.0.1
1. Improved the Ruby Gem Specification to support Rails v5.0

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
1. Improve the Model Extension concern to add the #assert_present! & the .assert_present! method

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
