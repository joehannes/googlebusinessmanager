import { useEffect, useState } from 'react'
import {
  Alert,
  Button,
  Card,
  Col,
  Form,
  Input,
  Layout,
  List,
  Menu,
  Modal,
  Row,
  Segmented,
  Select,
  Space,
  Steps,
  Statistic,
  Switch,
  Tag,
  Typography,
  message,
} from 'antd'
import {
  CloudUploadOutlined,
  CompassOutlined,
  CustomerServiceOutlined,
  RobotOutlined,
  SettingOutlined,
  SoundOutlined,
  StarOutlined,
  ThunderboltOutlined,
} from '@ant-design/icons'
import './App.css'

const { Content, Sider } = Layout
const { TextArea } = Input
const { Step } = Steps
const { Text } = Typography

type PropertyItem = {
  id: string
  title: string
  category: string
  description: string
  price: string
  location: string
  availability: string
  notes: string
}

type WorkspaceState = {
  businessName: string
  businessDirection: string
  location: string
  googleProject: string
  googleApiKey: string
  qwenApiKey: string
  autoSync: boolean
  properties: PropertyItem[]
}

type ViewMode = 'guided' | 'advanced'

interface SpeechRecognitionLike {
  continuous: boolean
  interimResults: boolean
  lang: string
  onresult: ((event: { results: ArrayLike<ArrayLike<{ transcript: string }>> }) => void) | null
  onerror: ((event: { error: string }) => void) | null
  onend: (() => void) | null
  start: () => void
  stop: () => void
}

declare global {
  interface Window {
    SpeechRecognition?: new () => SpeechRecognitionLike
    webkitSpeechRecognition?: new () => SpeechRecognitionLike
  }
}

const STORAGE_KEY = 'gmb-workspace-v1'

const initialState: WorkspaceState = {
  businessName: 'Northstar Studio',
  businessDirection: 'Boutique design studio and local service provider',
  location: 'Seattle, WA',
  googleProject: 'business-profile-ops',
  googleApiKey: '',
  qwenApiKey: '',
  autoSync: true,
  properties: [
    {
      id: '1',
      title: 'Spring refresh package',
      category: 'Service',
      description: 'Photography + profile refresh for local service offers.',
      price: '$199',
      location: 'Seattle, WA',
      availability: 'Open now',
      notes: 'Use friendly wording and highlight local trust.',
    },
    {
      id: '2',
      title: 'Weekend promotion',
      category: 'Offer',
      description: 'Limited-time special to boost local engagement.',
      price: '$49',
      location: 'Seattle, WA',
      availability: 'Ends Sunday',
      notes: 'Mention urgency and nearby service area.',
    },
  ],
}

function App() {
  const [workspace, setWorkspace] = useState<WorkspaceState>(initialState)
  const [viewMode, setViewMode] = useState<ViewMode>('guided')
  const [activeStep, setActiveStep] = useState(0)
  const [isListening, setIsListening] = useState(false)
  const [transcript, setTranscript] = useState('')
  const [selectedPropertyId, setSelectedPropertyId] = useState(initialState.properties[0].id)
  const [isSettingsOpen, setIsSettingsOpen] = useState(false)
  const [statusText, setStatusText] = useState('Ready to guide your next Google Business Profile update.')

  useEffect(() => {
    const raw = window.localStorage.getItem(STORAGE_KEY)
    if (!raw) {
      return
    }

    try {
      const parsed = JSON.parse(raw) as WorkspaceState
      setWorkspace(parsed)
      setSelectedPropertyId(parsed.properties[0]?.id ?? initialState.properties[0].id)
    } catch {
      window.localStorage.removeItem(STORAGE_KEY)
    }
  }, [])

  useEffect(() => {
    window.localStorage.setItem(STORAGE_KEY, JSON.stringify(workspace))
  }, [workspace])

  const selectedProperty = workspace.properties.find((property) => property.id === selectedPropertyId) ?? workspace.properties[0]

  const updateWorkspace = (updates: Partial<WorkspaceState>) => {
    setWorkspace((current) => ({ ...current, ...updates }))
  }

  const updateProperty = (propertyId: string, updates: Partial<PropertyItem>) => {
    setWorkspace((current) => ({
      ...current,
      properties: current.properties.map((property) => (property.id === propertyId ? { ...property, ...updates } : property)),
    }))
  }

  const addProperty = () => {
    const newProperty: PropertyItem = {
      id: crypto.randomUUID(),
      title: 'New offer',
      category: 'Offer',
      description: 'Add a short description for this update.',
      price: '$0',
      location: workspace.location,
      availability: 'New',
      notes: 'Use this to test a new bulk idea.',
    }

    setWorkspace((current) => ({ ...current, properties: [...current.properties, newProperty] }))
    setSelectedPropertyId(newProperty.id)
    setStatusText('A new property row is ready for formatting and AI assistance.')
  }

  const duplicateProperty = () => {
    if (!selectedProperty) {
      return
    }

    const duplicate: PropertyItem = {
      ...selectedProperty,
      id: crypto.randomUUID(),
      title: `${selectedProperty.title} copy`,
    }

    setWorkspace((current) => ({ ...current, properties: [...current.properties, duplicate] }))
    setSelectedPropertyId(duplicate.id)
    setStatusText('The selected profile item was duplicated for bulk editing.')
  }

  const saveWorkspace = async () => {
    const payload = JSON.stringify(workspace)
    window.localStorage.setItem(STORAGE_KEY, payload)
    setStatusText('Workspace saved locally and ready for Cloudflare sync when configured.')

    if (workspace.autoSync) {
      try {
        await fetch('/api/settings', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: payload,
        })
        setStatusText('Workspace saved locally and synced to the Cloudflare Pages function route.')
      } catch {
        setStatusText('Workspace saved locally. Cloudflare sync will be enabled once the KV binding is provisioned.')
      }
    }
  }

  const applyAiToProperty = async () => {
    if (!workspace.qwenApiKey) {
      message.warning('Add a Qwen API key to unlock AI assistance.')
      setIsSettingsOpen(true)
      return
    }

    if (!selectedProperty) {
      return
    }

    try {
      const prompt = `You are helping update a Google Business Profile. Use this transcript and current draft to return compact JSON with title, category, description, price, availability and notes. Transcript: ${transcript || 'No transcript yet'}. Draft: ${JSON.stringify(selectedProperty)}`
      const response = await fetch('https://dashscope.aliyuncs.com/compatible/openai/v1/chat/completions', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${workspace.qwenApiKey}`,
        },
        body: JSON.stringify({
          model: 'qwen-plus',
          messages: [
            { role: 'system', content: 'Return valid JSON only. Keep it concise.' },
            { role: 'user', content: prompt },
          ],
          temperature: 0.2,
        }),
      })

      const data = await response.json()
      const content = data.choices?.[0]?.message?.content ?? '{}'
      const parsed = JSON.parse(content.match(/\{[\s\S]*\}/)?.[0] ?? '{}')

      updateProperty(selectedProperty.id, {
        title: parsed.title ?? selectedProperty.title,
        category: parsed.category ?? selectedProperty.category,
        description: parsed.description ?? selectedProperty.description,
        price: parsed.price ?? selectedProperty.price,
        availability: parsed.availability ?? selectedProperty.availability,
        notes: parsed.notes ?? selectedProperty.notes,
      })

      setStatusText('AI suggestions were applied to the selected property row.')
      message.success('AI suggestions applied to the selected property.')
    } catch (error) {
      console.error(error)
      message.error('The Qwen request failed. Please verify the API key and endpoint access.')
      setStatusText('The AI draft could not be generated. Please confirm your Qwen setup.')
    }
  }

  const startVoiceCapture = () => {
    const SpeechRecognitionCtor = window.SpeechRecognition ?? window.webkitSpeechRecognition
    if (!SpeechRecognitionCtor) {
      message.warning('Speech recognition is not supported in this browser.')
      return
    }

    const recognition = new SpeechRecognitionCtor() as SpeechRecognitionLike
    recognition.continuous = false
    recognition.interimResults = true
    recognition.lang = 'en-US'
    recognition.onresult = (event) => {
      const nextTranscript = Array.from(event.results)
        .map((result) => result[0]?.transcript ?? '')
        .join(' ')
      setTranscript(nextTranscript)
      setStatusText('Voice transcript captured. You can apply it to the selected manager card.')
    }
    recognition.onerror = () => {
      setIsListening(false)
      setStatusText('Voice capture stopped. Try again with a browser that supports speech recognition.')
    }
    recognition.onend = () => {
      setIsListening(false)
    }

    recognition.start()
    setIsListening(true)
  }

  const steps = [
    'Set core business details',
    'Connect Google and Qwen helpers',
    'Bulk build offers and properties',
    'Review and publish to your workflow',
  ]

  return (
    <Layout className="app-shell">
      <Sider width={280} breakpoint="lg" collapsedWidth={0} className="sidebar">
        <div className="brand-block">
          <div className="brand-mark">GB</div>
          <div>
            <h1>Google Business Manager</h1>
            <p>Cloudflare-first workspace for local profile ops</p>
          </div>
        </div>
        <Menu
          mode="inline"
          defaultSelectedKeys={['overview']}
          items={[
            { key: 'overview', icon: <CompassOutlined />, label: 'Overview' },
            { key: 'setup', icon: <SettingOutlined />, label: 'Setup' },
            { key: 'ai', icon: <RobotOutlined />, label: 'AI helpers' },
            { key: 'bulk', icon: <CloudUploadOutlined />, label: 'Bulk tools' },
          ]}
        />
        <div className="sidebar-footer">
          <Tag color="purple">FE-only</Tag>
          <Tag color="blue">Cloudflare Pages ready</Tag>
          <Text type="secondary">Your data stays in-browser unless you enable Cloudflare sync.</Text>
        </div>
      </Sider>
      <Layout>
        <Content className="content-area">
          <div className="hero-card">
            <div>
              <Tag color="green">Vite + React + Ant Design</Tag>
              <h2>Run guided profile management for local businesses from one responsive workspace.</h2>
              <p>
                This setup combines general settings, repeatable property editing, guide-first onboarding,
                and a lightweight AI layer for dictation and bulk-fill actions.
              </p>
            </div>
            <div className="hero-actions">
              <Button type="primary" onClick={() => setIsSettingsOpen(true)}>
                Configure helpers
              </Button>
              <Button onClick={saveWorkspace}>Save workspace</Button>
            </div>
          </div>

          <div className="status-bar">
            <Space wrap>
              <Tag icon={<ThunderboltOutlined />} color="processing">
                AI assisted
              </Tag>
              <Tag icon={<CustomerServiceOutlined />} color="default">
                Voice driven
              </Tag>
              <Tag icon={<StarOutlined />} color="warning">
                Guided + bulk modes
              </Tag>
            </Space>
            <Text type="secondary">{statusText}</Text>
          </div>

          <Row gutter={[16, 16]} className="stats-row">
            <Col xs={24} md={8}>
              <Card>
                <Statistic title="Business focus" value={workspace.businessName} />
              </Card>
            </Col>
            <Col xs={24} md={8}>
              <Card>
                <Statistic title="Managed items" value={workspace.properties.length} />
              </Card>
            </Col>
            <Col xs={24} md={8}>
              <Card>
                <Statistic title="Cloudflare sync" value={workspace.autoSync ? 'On' : 'Off'} />
              </Card>
            </Col>
          </Row>

          <Card className="mode-card">
            <div className="mode-header">
              <div>
                <h3>Choose your working style</h3>
                <p>Switch between a step-by-step flow and an advanced bulk studio.</p>
              </div>
              <Segmented
                options={[
                  { label: 'Guided setup', value: 'guided' },
                  { label: 'Advanced workspace', value: 'advanced' },
                ]}
                value={viewMode}
                onChange={(value) => setViewMode(value as ViewMode)}
              />
            </div>
          </Card>

          {viewMode === 'guided' ? (
            <Card>
              <Steps current={activeStep} className="guide-steps">
                {steps.map((step) => (
                  <Step key={step} title={step} />
                ))}
              </Steps>

              <div className="guide-body">
                {activeStep === 0 && (
                  <Form layout="vertical">
                    <Row gutter={16}>
                      <Col xs={24} md={12}>
                        <Form.Item label="Business name">
                          <Input
                            value={workspace.businessName}
                            onChange={(event) => updateWorkspace({ businessName: event.target.value })}
                          />
                        </Form.Item>
                      </Col>
                      <Col xs={24} md={12}>
                        <Form.Item label="Business direction">
                          <Input
                            value={workspace.businessDirection}
                            onChange={(event) => updateWorkspace({ businessDirection: event.target.value })}
                          />
                        </Form.Item>
                      </Col>
                    </Row>
                    <Form.Item label="Primary location">
                      <Input
                        value={workspace.location}
                        onChange={(event) => updateWorkspace({ location: event.target.value })}
                      />
                    </Form.Item>
                  </Form>
                )}

                {activeStep === 1 && (
                  <div className="guide-grid">
                    <Alert
                      message="Google Cloud Console checklist"
                      description="Create a Google Cloud project, enable the Business Profile API, and create a restricted API key for profile admin actions."
                      type="info"
                      showIcon
                    />
                    <Alert
                      message="Qwen API key"
                      description="Paste a free Qwen compatible API key and the workspace will persist it locally and try to sync it through the Cloudflare function route."
                      type="success"
                      showIcon
                    />
                    <Button type="primary" onClick={() => window.open('https://console.cloud.google.com/', '_blank')}>
                      Open Google Cloud Console
                    </Button>
                    <Button onClick={() => setIsSettingsOpen(true)}>
                      Open Qwen and Google helper panel
                    </Button>
                  </div>
                )}

                {activeStep === 2 && (
                  <div>
                    <Button type="primary" onClick={addProperty} style={{ marginBottom: 16 }}>
                      Add property row
                    </Button>
                    <List
                      dataSource={workspace.properties}
                      renderItem={(property) => (
                        <List.Item>
                          <Card size="small" className="mini-card">
                            <Text strong>{property.title}</Text>
                            <p>{property.description}</p>
                            <Tag color="blue">{property.category}</Tag>
                            <Tag color="gold">{property.price}</Tag>
                          </Card>
                        </List.Item>
                      )}
                    />
                  </div>
                )}

                {activeStep === 3 && (
                  <div className="guide-grid">
                    <Alert
                      message="Ready to publish"
                      description="Use the voice capture panel and AI helper to speed up repeated property edits before you hand off to a team or client."
                      type="info"
                      showIcon
                    />
                    <Button onClick={saveWorkspace}>Save and prepare for next session</Button>
                  </div>
                )}
              </div>

              <div className="step-actions">
                <Button onClick={() => setActiveStep((current) => Math.max(0, current - 1))}>Previous</Button>
                <Button type="primary" onClick={() => setActiveStep((current) => Math.min(steps.length - 1, current + 1))}>
                  Next
                </Button>
              </div>
            </Card>
          ) : (
            <Row gutter={[16, 16]}>
              <Col xs={24} lg={12}>
                <Card title="General settings" extra={<Button type="link" onClick={() => setIsSettingsOpen(true)}>Open helpers</Button>}>
                  <Form layout="vertical">
                    <Form.Item label="Business name">
                      <Input
                        value={workspace.businessName}
                        onChange={(event) => updateWorkspace({ businessName: event.target.value })}
                      />
                    </Form.Item>
                    <Form.Item label="Business direction">
                      <Input
                        value={workspace.businessDirection}
                        onChange={(event) => updateWorkspace({ businessDirection: event.target.value })}
                      />
                    </Form.Item>
                    <Form.Item label="Primary location">
                      <Input
                        value={workspace.location}
                        onChange={(event) => updateWorkspace({ location: event.target.value })}
                      />
                    </Form.Item>
                    <Form.Item label="Google Cloud project">
                      <Input
                        value={workspace.googleProject}
                        onChange={(event) => updateWorkspace({ googleProject: event.target.value })}
                      />
                    </Form.Item>
                    <Form.Item label="Google API key">
                      <Input
                        value={workspace.googleApiKey}
                        onChange={(event) => updateWorkspace({ googleApiKey: event.target.value })}
                        placeholder="Paste your Google API key"
                      />
                    </Form.Item>
                    <Form.Item label="Cloudflare sync">
                      <Switch checked={workspace.autoSync} onChange={(checked) => updateWorkspace({ autoSync: checked })} />
                    </Form.Item>
                  </Form>
                </Card>

                <Card title="AI voice studio" className="ai-card" style={{ marginTop: 16 }}>
                  <Button icon={<SoundOutlined />} onClick={startVoiceCapture} loading={isListening}>
                    {isListening ? 'Listening…' : 'Start voice capture'}
                  </Button>
                  <TextArea
                    rows={4}
                    value={transcript}
                    onChange={(event) => setTranscript(event.target.value)}
                    placeholder="Talk naturally and let the AI turn your notes into profile-ready content."
                    style={{ marginTop: 12 }}
                  />
                  <div className="ai-actions">
                    <Button type="primary" onClick={applyAiToProperty}>
                      Apply AI suggestions
                    </Button>
                    <Button onClick={() => setTranscript('')}>Clear transcript</Button>
                  </div>
                </Card>
              </Col>

              <Col xs={24} lg={12}>
                <Card
                  title="Bulk property studio"
                  extra={
                    <Space>
                      <Button onClick={addProperty}>Add row</Button>
                      <Button onClick={duplicateProperty}>Duplicate</Button>
                    </Space>
                  }
                >
                  <div className="property-picker">
                    {workspace.properties.map((property) => (
                      <Button
                        key={property.id}
                        type={selectedProperty?.id === property.id ? 'primary' : 'default'}
                        onClick={() => setSelectedPropertyId(property.id)}
                      >
                        {property.title}
                      </Button>
                    ))}
                  </div>

                  {selectedProperty && (
                    <Form layout="vertical" className="property-form">
                      <Form.Item label="Title">
                        <Input
                          value={selectedProperty.title}
                          onChange={(event) => updateProperty(selectedProperty.id, { title: event.target.value })}
                        />
                      </Form.Item>
                      <Form.Item label="Category">
                        <Select
                          value={selectedProperty.category}
                          onChange={(value) => updateProperty(selectedProperty.id, { category: value })}
                          options={['Service', 'Offer', 'Event', 'Product'].map((option) => ({ value: option, label: option }))}
                        />
                      </Form.Item>
                      <Form.Item label="Description">
                        <TextArea
                          rows={3}
                          value={selectedProperty.description}
                          onChange={(event) => updateProperty(selectedProperty.id, { description: event.target.value })}
                        />
                      </Form.Item>
                      <Row gutter={16}>
                        <Col xs={24} md={12}>
                          <Form.Item label="Price">
                            <Input
                              value={selectedProperty.price}
                              onChange={(event) => updateProperty(selectedProperty.id, { price: event.target.value })}
                            />
                          </Form.Item>
                        </Col>
                        <Col xs={24} md={12}>
                          <Form.Item label="Availability">
                            <Input
                              value={selectedProperty.availability}
                              onChange={(event) => updateProperty(selectedProperty.id, { availability: event.target.value })}
                            />
                          </Form.Item>
                        </Col>
                      </Row>
                      <Form.Item label="Location">
                        <Input
                          value={selectedProperty.location}
                          onChange={(event) => updateProperty(selectedProperty.id, { location: event.target.value })}
                        />
                      </Form.Item>
                      <Form.Item label="Notes">
                        <TextArea
                          rows={2}
                          value={selectedProperty.notes}
                          onChange={(event) => updateProperty(selectedProperty.id, { notes: event.target.value })}
                        />
                      </Form.Item>
                    </Form>
                  )}
                </Card>
              </Col>
            </Row>
          )}
        </Content>
      </Layout>

      <Modal
        title="Settings and setup helpers"
        open={isSettingsOpen}
        onCancel={() => setIsSettingsOpen(false)}
        footer={null}
        width={760}
      >
        <Row gutter={[16, 16]}>
          <Col xs={24} md={12}>
            <Card title="Qwen free AI" className="modal-card">
              <p>Use a personal API key to unlock the dictation-to-profile assistant.</p>
              <Button type="primary" onClick={() => window.open('https://chat.qwen.ai/', '_blank')}>
                Open Qwen account setup
              </Button>
              <TextArea
                rows={4}
                className="modal-input"
                value={workspace.qwenApiKey}
                onChange={(event) => updateWorkspace({ qwenApiKey: event.target.value })}
                placeholder="Paste your Qwen-compatible API key"
              />
              <p className="helper-text">
                The key is stored in this browser for quick local access. The Cloudflare Pages function route can also receive it once KV is configured.
              </p>
            </Card>
          </Col>
          <Col xs={24} md={12}>
            <Card title="Google Cloud Console" className="modal-card">
              <p>Create the project, enable the Business Profile API, and generate a key for your profile administration flow.</p>
              <Button type="primary" onClick={() => window.open('https://console.cloud.google.com/apis/credentials', '_blank')}>
                Open Google Cloud Console
              </Button>
              <ul className="helper-list">
                <li>1. Create a new Google Cloud project.</li>
                <li>2. Enable the Business Profile API.</li>
                <li>3. Create an API key and secure it for local testing.</li>
                <li>4. Use the same business direction and location to guide profile updates.</li>
              </ul>
              <TextArea
                rows={4}
                className="modal-input"
                value={workspace.googleApiKey}
                onChange={(event) => updateWorkspace({ googleApiKey: event.target.value })}
                placeholder="Paste your Google API key"
              />
            </Card>
          </Col>
        </Row>
      </Modal>
    </Layout>
  )
}

export default App
