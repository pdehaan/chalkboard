path            = require "path"
_               = require "lodash"
languages       = require "../../resources/languages.json"
definitions     = require "../../resources/definitions/base.json"
commentRegexStr = "\\s*(?:@(\\w+))?(?:\\s*(.*))?"

util = {
  #
  # @function
  # @name captialize
  # @description
  # Capitalize the first letter of a string
  # @param {String} str String to be capitalized
  # @returns {String} Capitalized string
  #
  capitalize: (str = "") ->
    return str unless str
    str[0].toUpperCase() + str[1..]

  #
  # @function
  # @name escape
  # @description
  # Escape special regular expression symbol
  # @param {String} text Regular expression text
  # @returns {String} Escaped text
  #
  escape: (text) ->
    text.replace /[-[\]{}()*+?.,\\\/^$|#\s]/g, "\\$&"

  #
  # @function
  # @nam repeatChar
  # @description
  # Repeat a character multiple times
  # @param {Sting} char Character to repeat
  # @param {Integer} count Number of times to repeat the character
  # @returns {String} Processed string
  #
  repeatChar: (char, count = 0) ->
    Array(count+1).join char

  getLanguages: (source, options = {}) ->
    ext  = path.extname(source) or path.basename(source)
    lang = languages[ext]

    # Should fail silently when langauge is not supported
    # and move onto the next file
    return null unless lang?

    symbol            = util.escape lang.symbol
    regex             = "^\\s*(?:#{symbol}){1,2}#{commentRegexStr}"
    lang.commentRegex = new RegExp regex
    lang.lineRegex    = new RegExp "^\\s*(?:#{symbol}){1,2}\\s+(.*)"
    lang.blockRegex   = new RegExp util.escape(lang.block) if lang.block?

    lang.startRegex = new RegExp util.escape(lang.start) if lang.start?
    lang.endRegex   = new RegExp util.escape(lang.end)   if lang.end?

    return lang

  #
  # @chalk function
  # @function
  # @private
  # @name formatKeyValue
  # @description
  # Format value with type and description
  # @param {String}  key     Tag name
  # @param {String}  value   User input for the tag
  # @param {Boolean} newLine If a new line should be appended to the end
  #  (default true)
  # @param {Integer}  headerLevel The header level of the section name (default 3)
  # @returns {String} Formatted   Markdown string based on key and value
  #
  formatKeyValue: (key, value, newLine = true, headerLevel = 3) ->
    def         = definitions[key]
    displayName = if def?.displayName? then def.displayName else key

    output  = util.repeatChar "#", headerLevel
    output += " #{util.capitalize(displayName)}\n"
    if _.isArray(value)
      for element in value

        # returns and param
        if _.isObject(element)
          if element.name?
            output += "**#{element.name}**  \n"
          if element.type?
            output += "Type: `#{element.type}`  \n"
          if element.description? and element.description
            output += "#{element.description}  \n"

        # Everything else with just string
        else
          output += "-   #{element}  \n"

    else if _.isString(value)
      output += "#{value}"

    output += "\n" if newLine

    return output

}

module.exports = util
