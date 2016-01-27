module.exports =
class SnippetsProvider
  selector: '*'
  disableForSelector: '.comment, .string'
  inclusionPriority: 1
  suggestionPriority: 2

  filterSuggestions: true

  constructor: ->
    @showIcon = atom.config.get('autocomplete-plus.defaultProvider') is 'Symbol'
    @snippetsSource =
      snippetsForScopes: (scopeDescriptor) ->
        atom.config.get('snippets', {scope: scopeDescriptor})

  setSnippetsSource: (snippetsSource) ->
    if typeof snippetsSource?.snippetsForScopes is "function"
      @snippetsSource = snippetsSource

  getSuggestions: ({scopeDescriptor, prefix, editor, bufferPosition}) ->
    return unless prefix?.length
    prefix = @getPrefix(editor, bufferPosition)
    scopeSnippets = @snippetsSource.snippetsForScopes(scopeDescriptor)
    @findSuggestionsForPrefix(scopeSnippets, prefix)

  getPrefix: (editor, bufferPosition) ->
    regex = /[.]*[\w0-9_-]+$/
    line = editor.getTextInRange([[bufferPosition.row, 0], bufferPosition])
    line.match(regex)?[0] or ''

  findSuggestionsForPrefix: (snippets, prefix) ->
    return [] unless snippets?

    suggestions = []
    for snippetPrefix, snippet of snippets
      continue unless snippet and snippetPrefix and prefix and firstCharsEqual(snippetPrefix, prefix)
      suggestions.push
        iconHTML: if @showIcon then undefined else false
        type: 'snippet'
        text: snippet.prefix
        replacementPrefix: prefix
        rightLabel: snippet.name
        description: snippet.description
        descriptionMoreURL: snippet.descriptionMoreURL

    suggestions.sort(ascendingPrefixComparator)
    suggestions

  onDidInsertSuggestion: ({editor}) ->
    atom.commands.dispatch(atom.views.getView(editor), 'snippets:expand')

ascendingPrefixComparator = (a, b) -> a.prefix  - b.prefix

firstCharsEqual = (str1, str2) ->
  str1[0].toLowerCase() is str2[0].toLowerCase()
