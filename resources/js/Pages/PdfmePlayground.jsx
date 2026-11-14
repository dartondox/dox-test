import { useEffect, useRef, useState } from 'react'
import { Designer } from '@pdfme/ui'
import { generate } from '@pdfme/generator'
import {
  barcodes,
  checkbox,
  date,
  dateTime,
  ellipse,
  image,
  line,
  radioGroup,
  rectangle,
  select,
  svg,
  text,
  time,
} from '@pdfme/schemas'
import Nav from '../Nav'

/// The schema types dox_pdf_me supports (not table, multiVariableText, ...).
const plugins = {
  Text: text,
  Image: image,
  SVG: svg,
  Line: line,
  Rectangle: rectangle,
  Ellipse: ellipse,
  ...barcodes,
  Date: date,
  Time: time,
  DateTime: dateTime,
  Checkbox: checkbox,
  RadioGroup: radioGroup,
  Select: select,
}

const blankA4 = { width: 210, height: 297, padding: [0, 0, 0, 0] }

const sampleImage =
  'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAIAAABvFaqvAAADnklEQVR42hXUqxpFERSF0Z1lWZZlWZZlWZZlWZZlWf6zLHuO43iA8Vm3+X0f4kN+qA/9YT7sh/vwH+EjfqSP/FE+6kf76B/jY36sDz72x/m4H98nEAIpUAItMAIrcAIvCIIoSIIsKIIqaIIuGIIpWAIEW3AEVzxIIiRSoiRaYiRW4iReEiRRkiRZUiRV0iRdMiRTsiRItuRIrnyQQiikQim0wiiswim8IiiiIimyoiiqoim6YiimYilQbMVRXPUgjdBIjdJojdFYjdN4TdBETdJkTdFUTdN0zdBMzdKg2ZqjufpBBmGQBmXQBmOwBmfwhmCIhmTIhmKohmbohmGYhmXAsA3HcM2DLMIiLcqiLcZiLc7iLcESLcmSLcVSLc3SLcMyLcuCZVuO5doHOYRDOpRDO4zDOpzDO4IjOpIjO4qjOpqjO4ZjOpYDx3Ycx3UP8giP9CiP9hiP9TiP9wRP9CRP9hRP9TRP9wzP9CwPnu05nusfFBABGVABHTABG3ABHwiBGEiBHCiBGmiBHhiBGVgBAjtwAjc8KCIiMqIiOmIiNuIiPhIiMZIiOVIiNdIiPTIiM7IiRHbkRG58UEIkZEIldMIkbMIlfCIkYiIlcqIkaqIlemIkZmIlSOzESdz0oIzIyIzK6IzJ2IzL+EzIxEzK5EzJ1EzL9MzIzMzKkNmZk7n5QQVRkAVV0AVTsAVX8IVQiIVUyIVSqIVW6IVRmIVVoLALp3DLgyqiIiuqoiumYiuu4iuhEiupkiulUiut0iujMiurQmVXTuXWBzVEQzZUQzdMwzZcwzdCIzZSIzdKozZaozdGYzZWg8ZunMZtD+qIjuyoju6Yju24ju+ETuykTu6UTu20Tu+MzuysDp3dOZ3bHzQQAzlQAz0wAztwAz8IgzhIgzwogzpogz4YgzlYAwZ7cAZ3PGgiJnKiJnpiJnbiJn4SJnGSJnlSJnXSJn0yJnOyJkz25EzufNBCLORCLfTCLOzCLfwiLOIiLfKiLOqiLfpiLOZiLVjsxVnc9aB/YL6oeyH14uUFwzvpd4zvjN4BvNV9S/fW5Q36jeg197XlFfS+8pD/23Dgvvj+NmIjN2qjN2ZjN27jN2ETN2mTN2VTN23TN2MzN2v/mb05m7sfdBAHeVAHfTAHe3AHfwiHeEiHfCiHemiHfhiHeVjn/5l9OId7HnQRF3lRF30xF3txF38Jl3hJl3wpl3ppl34Zl3lZ91/SvpzLvfwAj0rHrlvy/HQAAAAASUVORK5CYII='

const sampleTemplate = {
  basePdf: blankA4,
  schemas: [
    [
      {
        name: 'title',
        type: 'text',
        content: 'Hello from dox_pdf_me',
        position: { x: 20, y: 20 },
        width: 170,
        height: 14,
        fontSize: 24,
      },
      {
        name: 'link',
        type: 'qrcode',
        content: 'https://dartondox.dev',
        position: { x: 20, y: 45 },
        width: 35,
        height: 35,
      },
      {
        name: 'logo',
        type: 'image',
        content: sampleImage,
        position: { x: 70, y: 45 },
        width: 35,
        height: 35,
      },
      {
        name: 'day',
        type: 'date',
        content: '2026-11-14',
        format: 'yyyy/MM/dd',
        position: { x: 120, y: 55 },
        width: 50,
        height: 10,
        fontSize: 14,
      },
      {
        name: 'rule',
        type: 'line',
        position: { x: 20, y: 90 },
        width: 170,
        height: 1,
        color: '#333333',
        readOnly: true,
      },
    ],
  ],
}

/// One input record: the `content` of each editable schema.
function inputsOf(template) {
  const record = {}
  for (const page of template.schemas) {
    for (const schema of page) {
      if (!schema.readOnly) record[schema.name] = schema.content ?? ''
    }
  }
  return JSON.stringify([record], null, 2)
}

function readDataUri(file) {
  return new Promise(function (resolve, reject) {
    const reader = new FileReader()
    reader.onload = function () {
      resolve(reader.result)
    }
    reader.onerror = reject
    reader.readAsDataURL(file)
  })
}

function pdfUrl(bytes) {
  return URL.createObjectURL(new Blob([bytes], { type: 'application/pdf' }))
}

const box = { flex: 1, minWidth: 320 }
const frame = { width: '100%', height: '80vh', border: '1px solid #ccc' }

export default function PdfmePlayground() {
  const container = useRef(null)
  const designer = useRef(null)
  const [inputs, setInputs] = useState(inputsOf(sampleTemplate))
  const [dox, setDox] = useState(null)
  const [js, setJs] = useState(null)
  const [busy, setBusy] = useState(false)

  useEffect(function () {
    designer.current = new Designer({
      domContainer: container.current,
      template: sampleTemplate,
      plugins,
    })
    return function () {
      designer.current.destroy()
    }
  }, [])

  /// The current template and inputs. Throws on bad inputs JSON.
  function current() {
    return { template: designer.current.getTemplate(), inputs: JSON.parse(inputs) }
  }

  function setBasePdf(basePdf) {
    designer.current.updateTemplate({ ...designer.current.getTemplate(), basePdf })
  }

  async function upload(e) {
    const file = e.target.files[0]
    if (file) setBasePdf(await readDataUri(file))
    e.target.value = ''
  }

  function resetInputs() {
    setInputs(inputsOf(designer.current.getTemplate()))
  }

  /// POST /api/pdfme/generate: the PDF of dox_pdf_me.
  async function runDox(body) {
    const start = performance.now()
    try {
      const res = await fetch('/api/pdfme/generate', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body),
      })
      const total = Math.round(performance.now() - start)
      if (!res.ok) {
        return { error: `${res.status}: ${await res.text()}` }
      }
      const server = res.headers.get('X-Generate-Ms')
      return { url: pdfUrl(await res.arrayBuffer()), time: `${server} ms on the server, ${total} ms in all` }
    } catch (err) {
      return { error: String(err) }
    }
  }

  /// generate() of @pdfme/generator in the browser.
  async function runJs(body) {
    const start = performance.now()
    try {
      const bytes = await generate({ ...body, plugins })
      return { url: pdfUrl(bytes), time: `${Math.round(performance.now() - start)} ms in the browser` }
    } catch (err) {
      return { error: String(err) }
    }
  }

  function show(setter, result) {
    setter(function (old) {
      if (old?.url) URL.revokeObjectURL(old.url)
      return result
    })
  }

  async function run(compare) {
    let body
    try {
      body = current()
    } catch (err) {
      show(setDox, { error: `Inputs are not valid JSON: ${err.message}` })
      return
    }
    setBusy(true)
    show(setDox, await runDox(body))
    show(setJs, compare ? await runJs(body) : null)
    setBusy(false)
  }

  return (
    <main>
      <Nav />
      <h1>pdfme playground</h1>
      <p>
        Design a template, then make the PDF with dox_pdf_me (Dart, on the server) and with pdfme
        (in the browser).
      </p>
      <p>
        <label>
          Upload base PDF <input type="file" accept="application/pdf" onChange={upload} />
        </label>{' '}
        <button onClick={() => setBasePdf(blankA4)}>Blank A4</button>
      </p>
      <div ref={container} style={{ height: '75vh', border: '1px solid #ccc' }} />
      <h2>Inputs</h2>
      <textarea
        value={inputs}
        onChange={(e) => setInputs(e.target.value)}
        rows={10}
        style={{ width: '100%', fontFamily: 'monospace' }}
      />
      <p>
        <button onClick={resetInputs}>Reset inputs from template</button>{' '}
        <button disabled={busy} onClick={() => run(false)}>
          Generate with dox_pdf_me
        </button>{' '}
        <button disabled={busy} onClick={() => run(true)}>
          Compare with pdfme
        </button>
      </p>
      <div style={{ display: 'flex', gap: 16, flexWrap: 'wrap' }}>
        <Result title="dox_pdf_me" result={dox} />
        {js && <Result title="pdfme (browser)" result={js} />}
      </div>
    </main>
  )
}

function Result({ title, result }) {
  if (!result) return null
  return (
    <section style={box}>
      <h3>{title}</h3>
      {result.error ? (
        <pre style={{ color: 'red', whiteSpace: 'pre-wrap' }}>{result.error}</pre>
      ) : (
        <>
          <p>{result.time}</p>
          <iframe title={title} src={result.url} style={frame} />
        </>
      )}
    </section>
  )
}
