/// The editable fields of a template: { name: content }.
export function editableFields(template) {
  const fields = {}
  for (const page of template.schemas) {
    for (const schema of page) {
      if (!schema.readOnly) fields[schema.name] = schema.content ?? ''
    }
  }
  return fields
}

/// Moves the inputs JSON text from the old template to the new one.
/// New fields get their `content`. Removed fields lose their key.
/// Edited values stay, unless the input still equals the old content:
/// then it follows the new content.
/// Returns null when the text is not a JSON array of objects.
export function syncInputs(text, oldTemplate, newTemplate) {
  let records
  try {
    records = JSON.parse(text)
  } catch {
    return null
  }
  if (!Array.isArray(records) || records.some((r) => r === null || typeof r !== 'object' || Array.isArray(r))) {
    return null
  }
  const before = editableFields(oldTemplate)
  const after = editableFields(newTemplate)
  const next = records.map(function (record) {
    const merged = {}
    for (const name of Object.keys(after)) {
      const keep = name in record && !(name in before && record[name] === before[name] && before[name] !== after[name])
      merged[name] = keep ? record[name] : after[name]
    }
    return merged
  })
  return JSON.stringify(next, null, 2)
}
