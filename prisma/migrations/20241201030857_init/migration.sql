-- CreateEnum
CREATE TYPE "AddressSource" AS ENUM ('manual', 'google_api', 'crm_import');

-- CreateEnum
CREATE TYPE "AgentStatus" AS ENUM ('Active', 'Inactive');

-- CreateEnum
CREATE TYPE "CallStatus" AS ENUM ('Completed', 'Missed', 'Failed', 'InProgress');

-- CreateEnum
CREATE TYPE "NotificationType" AS ENUM ('info', 'warning', 'alert');

-- CreateEnum
CREATE TYPE "RecipientType" AS ENUM ('user', 'business', 'system');

-- CreateEnum
CREATE TYPE "TicketStatus" AS ENUM ('Open', 'InProgress', 'Resolved', 'Closed');

-- CreateEnum
CREATE TYPE "TicketPriority" AS ENUM ('Low', 'Medium', 'High', 'Urgent');

-- CreateEnum
CREATE TYPE "EventType" AS ENUM ('Call', 'Meeting', 'Webinar', 'Training');

-- CreateEnum
CREATE TYPE "MessageStatus" AS ENUM ('Sent', 'Delivered', 'Failed', 'Read');

-- CreateEnum
CREATE TYPE "MessageDirection" AS ENUM ('Incoming', 'Outgoing');

-- CreateEnum
CREATE TYPE "IntegrationType" AS ENUM ('CRM', 'WhatsApp', 'GoHighLevel', 'Slack', 'Email', 'Custom');

-- CreateEnum
CREATE TYPE "SentimentLabel" AS ENUM ('Positive', 'Neutral', 'Negative');

-- CreateEnum
CREATE TYPE "WhatsAppMessageType" AS ENUM ('Text', 'Image', 'Video', 'Document', 'Audio', 'Sticker', 'Location', 'Contact', 'Template');

-- CreateEnum
CREATE TYPE "SeverityLevel" AS ENUM ('Critical', 'High', 'Medium', 'Low', 'Info');

-- CreateEnum
CREATE TYPE "TriggerSource" AS ENUM ('AI', 'User', 'System', 'API', 'Scheduler');

-- CreateEnum
CREATE TYPE "SubscriptionTier" AS ENUM ('Free', 'Basic', 'Premium', 'Enterprise', 'Custom');

-- CreateEnum
CREATE TYPE "ErrorCategory" AS ENUM ('UserError', 'SystemError', 'NetworkError', 'DatabaseError', 'AuthenticationError', 'AuthorizationError', 'ValidationError');

-- CreateTable
CREATE TABLE "users" (
    "id" TEXT NOT NULL,
    "userUuid" TEXT NOT NULL,
    "firstName" TEXT NOT NULL,
    "lastName" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "phone" TEXT,
    "passwordHash" TEXT,
    "googleId" TEXT,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "emailVerified" TIMESTAMP(3),
    "image" TEXT,
    "mfaEnabled" BOOLEAN NOT NULL DEFAULT false,
    "lastLoginAt" TIMESTAMP(3),
    "deletedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "accounts" (
    "id" SERIAL NOT NULL,
    "userId" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "provider" TEXT NOT NULL,
    "providerAccountId" TEXT NOT NULL,
    "refreshToken" TEXT,
    "accessToken" TEXT,
    "expiresAt" INTEGER,
    "tokenType" TEXT,
    "scope" TEXT,
    "idToken" TEXT,
    "sessionState" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "accounts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "sessions" (
    "id" SERIAL NOT NULL,
    "sessionToken" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "lastActivityAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "ipAddress" TEXT,
    "userAgent" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "sessions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "verification_tokens" (
    "identifier" TEXT NOT NULL,
    "token" TEXT NOT NULL,
    "expires" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "verification_tokens_pkey" PRIMARY KEY ("identifier","token")
);

-- CreateTable
CREATE TABLE "businesses" (
    "id" SERIAL NOT NULL,
    "businessUuid" TEXT NOT NULL,
    "businessName" TEXT NOT NULL,
    "createdById" TEXT NOT NULL,
    "googlePlaceId" TEXT,
    "streetAddress" TEXT NOT NULL,
    "city" TEXT NOT NULL,
    "state" TEXT NOT NULL,
    "postalCode" TEXT NOT NULL,
    "country" TEXT NOT NULL,
    "latitude" DOUBLE PRECISION,
    "longitude" DOUBLE PRECISION,
    "isAutofill" BOOLEAN NOT NULL DEFAULT false,
    "source" "AddressSource" NOT NULL DEFAULT 'manual',
    "timezone" TEXT NOT NULL DEFAULT 'UTC',
    "primaryLanguage" TEXT NOT NULL DEFAULT 'en',
    "supportedLanguages" TEXT[] DEFAULT ARRAY['en']::TEXT[],
    "subscriptionTier" "SubscriptionTier" NOT NULL DEFAULT 'Free',
    "maxAgents" INTEGER NOT NULL DEFAULT 1,
    "settings" JSONB,
    "operatingHours" JSONB,
    "industryType" TEXT,
    "deletedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "businesses_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "roles" (
    "id" SERIAL NOT NULL,
    "roleUuid" TEXT NOT NULL,
    "businessId" INTEGER NOT NULL,
    "roleName" TEXT NOT NULL,
    "description" TEXT,
    "permissions" JSONB,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "roles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "business_users" (
    "id" SERIAL NOT NULL,
    "businessId" INTEGER NOT NULL,
    "userId" TEXT NOT NULL,
    "roleId" INTEGER NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "business_users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ai_agents" (
    "id" SERIAL NOT NULL,
    "agentUuid" TEXT NOT NULL,
    "businessId" INTEGER NOT NULL,
    "agentName" TEXT NOT NULL,
    "agentRole" TEXT NOT NULL,
    "agentSettings" JSONB,
    "createdById" TEXT NOT NULL,
    "status" "AgentStatus" NOT NULL DEFAULT 'Active',
    "version" TEXT,
    "voiceConfig" JSONB,
    "languageModels" TEXT[],
    "activeHours" JSONB,
    "responseTemplates" JSONB,
    "callLimit" INTEGER,
    "specializations" TEXT[],
    "deletedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ai_agents_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "agent_calls" (
    "id" SERIAL NOT NULL,
    "callUuid" TEXT NOT NULL,
    "businessId" INTEGER NOT NULL,
    "agentId" INTEGER NOT NULL,
    "callerName" TEXT,
    "callerContact" TEXT,
    "callDuration" INTEGER NOT NULL,
    "callStatus" "CallStatus" NOT NULL DEFAULT 'Completed',
    "callSummary" TEXT,
    "callRecordingUrl" TEXT,
    "deletedAt" TIMESTAMP(3),
    "timestamp" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "sentimentScore" DOUBLE PRECISION,
    "sentimentLabel" "SentimentLabel",
    "s3RecordingUrl" TEXT,
    "analysisData" JSONB,
    "transcriptionText" TEXT,
    "keyTopics" TEXT[],
    "followUpRequired" BOOLEAN NOT NULL DEFAULT false,
    "customerSatisfactionScore" DOUBLE PRECISION,
    "callIntent" TEXT,
    "languageUsed" TEXT,
    "waitTime" INTEGER,
    "transferCount" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "agent_calls_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "api_keys" (
    "id" SERIAL NOT NULL,
    "apiKeyHash" TEXT NOT NULL,
    "businessId" INTEGER NOT NULL,
    "userId" TEXT NOT NULL,
    "keyName" TEXT NOT NULL,
    "permissions" JSONB NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "lastUsedAt" TIMESTAMP(3),
    "usageCount" INTEGER NOT NULL DEFAULT 0,
    "rateLimit" INTEGER,
    "dailyLimit" INTEGER,
    "monthlyLimit" INTEGER,
    "dailyUsage" INTEGER NOT NULL DEFAULT 0,
    "monthlyUsage" INTEGER NOT NULL DEFAULT 0,
    "lastResetAt" TIMESTAMP(3),
    "deletedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "api_keys_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "api_usage" (
    "id" SERIAL NOT NULL,
    "businessId" INTEGER NOT NULL,
    "apiKeyId" INTEGER NOT NULL,
    "endpoint" TEXT NOT NULL,
    "requestCount" INTEGER NOT NULL DEFAULT 0,
    "lastRequestAt" TIMESTAMP(3),
    "dailyLimit" INTEGER,
    "rateLimitReset" TIMESTAMP(3),

    CONSTRAINT "api_usage_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "integrations" (
    "id" SERIAL NOT NULL,
    "businessId" INTEGER NOT NULL,
    "type" "IntegrationType" NOT NULL,
    "name" TEXT NOT NULL,
    "apiKey" TEXT,
    "accessToken" TEXT,
    "refreshToken" TEXT,
    "tokenExpiry" TIMESTAMP(3),
    "config" JSONB,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "webhookUrl" TEXT,
    "webhookSecret" TEXT,
    "retryConfig" JSONB,
    "rateLimits" JSONB,
    "lastSyncStatus" TEXT,
    "lastSyncError" TEXT,
    "syncFrequency" TEXT,
    "deletedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "integrations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tickets" (
    "id" SERIAL NOT NULL,
    "ticketUuid" TEXT NOT NULL,
    "businessId" INTEGER NOT NULL,
    "agentCallId" INTEGER,
    "raisedById" TEXT,
    "assignedToId" TEXT,
    "status" "TicketStatus" NOT NULL DEFAULT 'Open',
    "priority" "TicketPriority" NOT NULL DEFAULT 'Medium',
    "subject" TEXT NOT NULL,
    "description" TEXT,
    "tags" TEXT[],
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "closedAt" TIMESTAMP(3),
    "deletedAt" TIMESTAMP(3),

    CONSTRAINT "tickets_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "schedules" (
    "id" SERIAL NOT NULL,
    "scheduleUuid" TEXT NOT NULL,
    "businessId" INTEGER NOT NULL,
    "agentCallId" INTEGER,
    "scheduledById" TEXT,
    "scheduledFor" TEXT NOT NULL,
    "eventType" "EventType" NOT NULL,
    "startTime" TIMESTAMP(3) NOT NULL,
    "endTime" TIMESTAMP(3),
    "location" TEXT,
    "details" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "deletedAt" TIMESTAMP(3),

    CONSTRAINT "schedules_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "email_logs" (
    "id" SERIAL NOT NULL,
    "emailUuid" TEXT NOT NULL,
    "businessId" INTEGER NOT NULL,
    "agentCallId" INTEGER,
    "sentById" TEXT,
    "recipientEmail" TEXT NOT NULL,
    "subject" TEXT NOT NULL,
    "body" TEXT NOT NULL,
    "status" "MessageStatus" NOT NULL DEFAULT 'Sent',
    "sentAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deliveredAt" TIMESTAMP(3),
    "readAt" TIMESTAMP(3),
    "errorMessage" TEXT,
    "deletedAt" TIMESTAMP(3),

    CONSTRAINT "email_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "text_message_logs" (
    "id" SERIAL NOT NULL,
    "messageUuid" TEXT NOT NULL,
    "businessId" INTEGER NOT NULL,
    "agentCallId" INTEGER,
    "sentById" TEXT,
    "recipientNumber" TEXT NOT NULL,
    "messageContent" TEXT NOT NULL,
    "status" "MessageStatus" NOT NULL DEFAULT 'Sent',
    "sentAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deliveredAt" TIMESTAMP(3),
    "readAt" TIMESTAMP(3),
    "errorMessage" TEXT,
    "deletedAt" TIMESTAMP(3),

    CONSTRAINT "text_message_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "whatsapp_messages" (
    "id" SERIAL NOT NULL,
    "messageUuid" TEXT NOT NULL,
    "businessId" INTEGER NOT NULL,
    "agentCallId" INTEGER,
    "sentById" TEXT,
    "recipientNumber" TEXT NOT NULL,
    "messageContent" TEXT,
    "messageType" "WhatsAppMessageType" NOT NULL,
    "mediaUrl" TEXT,
    "mediaCaption" TEXT,
    "direction" "MessageDirection" NOT NULL,
    "status" "MessageStatus" NOT NULL DEFAULT 'Sent',
    "timestamp" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deliveredAt" TIMESTAMP(3),
    "readAt" TIMESTAMP(3),
    "errorMessage" TEXT,
    "deletedAt" TIMESTAMP(3),

    CONSTRAINT "whatsapp_messages_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "audit_logs" (
    "id" SERIAL NOT NULL,
    "userId" TEXT,
    "action" TEXT NOT NULL,
    "outcome" TEXT NOT NULL,
    "resourceType" TEXT,
    "resourceId" INTEGER,
    "details" JSONB,
    "ipAddress" TEXT,
    "userAgent" TEXT,
    "timestamp" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "audit_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "notifications" (
    "id" SERIAL NOT NULL,
    "recipientType" "RecipientType" NOT NULL,
    "recipientId" INTEGER,
    "localizedMessages" JSONB NOT NULL,
    "notificationType" "NotificationType" NOT NULL DEFAULT 'info',
    "isRead" BOOLEAN NOT NULL DEFAULT false,
    "metadata" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deletedAt" TIMESTAMP(3),

    CONSTRAINT "notifications_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "error_logs" (
    "id" SERIAL NOT NULL,
    "errorCode" TEXT,
    "errorMessage" TEXT NOT NULL,
    "stackTrace" TEXT,
    "module" TEXT,
    "details" JSONB,
    "severity" "SeverityLevel" NOT NULL,
    "errorCategory" "ErrorCategory",
    "resolved" BOOLEAN NOT NULL DEFAULT false,
    "resolvedAt" TIMESTAMP(3),
    "resolvedBy" TEXT,
    "affectedUsers" INTEGER,
    "timestamp" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "error_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "data_retention_policies" (
    "id" SERIAL NOT NULL,
    "businessId" INTEGER NOT NULL,
    "dataType" TEXT NOT NULL,
    "retentionDays" INTEGER NOT NULL,
    "autoDelete" BOOLEAN NOT NULL DEFAULT true,
    "lastCleanup" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "data_retention_policies_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "quality_metrics" (
    "id" SERIAL NOT NULL,
    "businessId" INTEGER NOT NULL,
    "agentId" INTEGER NOT NULL,
    "callId" INTEGER NOT NULL,
    "metricType" TEXT NOT NULL,
    "score" DOUBLE PRECISION NOT NULL,
    "feedback" TEXT,
    "reviewedBy" TEXT,
    "reviewedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "quality_metrics_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "events" (
    "id" SERIAL NOT NULL,
    "eventType" TEXT NOT NULL,
    "userId" TEXT,
    "businessId" INTEGER,
    "triggerSource" "TriggerSource" NOT NULL,
    "details" JSONB,
    "timestamp" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "events_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "_UserRoles" (
    "A" INTEGER NOT NULL,
    "B" TEXT NOT NULL,

    CONSTRAINT "_UserRoles_AB_pkey" PRIMARY KEY ("A","B")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_userUuid_key" ON "users"("userUuid");

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE UNIQUE INDEX "users_googleId_key" ON "users"("googleId");

-- CreateIndex
CREATE UNIQUE INDEX "accounts_provider_providerAccountId_key" ON "accounts"("provider", "providerAccountId");

-- CreateIndex
CREATE UNIQUE INDEX "sessions_sessionToken_key" ON "sessions"("sessionToken");

-- CreateIndex
CREATE UNIQUE INDEX "businesses_businessUuid_key" ON "businesses"("businessUuid");

-- CreateIndex
CREATE UNIQUE INDEX "roles_roleUuid_key" ON "roles"("roleUuid");

-- CreateIndex
CREATE UNIQUE INDEX "roles_businessId_roleName_key" ON "roles"("businessId", "roleName");

-- CreateIndex
CREATE UNIQUE INDEX "business_users_businessId_userId_key" ON "business_users"("businessId", "userId");

-- CreateIndex
CREATE UNIQUE INDEX "ai_agents_agentUuid_key" ON "ai_agents"("agentUuid");

-- CreateIndex
CREATE UNIQUE INDEX "agent_calls_callUuid_key" ON "agent_calls"("callUuid");

-- CreateIndex
CREATE INDEX "agent_calls_businessId_timestamp_callStatus_idx" ON "agent_calls"("businessId", "timestamp", "callStatus");

-- CreateIndex
CREATE UNIQUE INDEX "api_keys_apiKeyHash_key" ON "api_keys"("apiKeyHash");

-- CreateIndex
CREATE INDEX "api_usage_businessId_endpoint_idx" ON "api_usage"("businessId", "endpoint");

-- CreateIndex
CREATE UNIQUE INDEX "api_usage_businessId_apiKeyId_endpoint_key" ON "api_usage"("businessId", "apiKeyId", "endpoint");

-- CreateIndex
CREATE UNIQUE INDEX "tickets_ticketUuid_key" ON "tickets"("ticketUuid");

-- CreateIndex
CREATE UNIQUE INDEX "schedules_scheduleUuid_key" ON "schedules"("scheduleUuid");

-- CreateIndex
CREATE UNIQUE INDEX "email_logs_emailUuid_key" ON "email_logs"("emailUuid");

-- CreateIndex
CREATE UNIQUE INDEX "text_message_logs_messageUuid_key" ON "text_message_logs"("messageUuid");

-- CreateIndex
CREATE UNIQUE INDEX "whatsapp_messages_messageUuid_key" ON "whatsapp_messages"("messageUuid");

-- CreateIndex
CREATE INDEX "whatsapp_messages_businessId_messageType_timestamp_idx" ON "whatsapp_messages"("businessId", "messageType", "timestamp");

-- CreateIndex
CREATE INDEX "audit_logs_userId_timestamp_idx" ON "audit_logs"("userId", "timestamp");

-- CreateIndex
CREATE INDEX "notifications_recipientType_recipientId_idx" ON "notifications"("recipientType", "recipientId");

-- CreateIndex
CREATE INDEX "notifications_isRead_createdAt_idx" ON "notifications"("isRead", "createdAt");

-- CreateIndex
CREATE INDEX "error_logs_severity_timestamp_idx" ON "error_logs"("severity", "timestamp");

-- CreateIndex
CREATE UNIQUE INDEX "data_retention_policies_businessId_dataType_key" ON "data_retention_policies"("businessId", "dataType");

-- CreateIndex
CREATE INDEX "quality_metrics_agentId_metricType_idx" ON "quality_metrics"("agentId", "metricType");

-- CreateIndex
CREATE INDEX "events_eventType_timestamp_idx" ON "events"("eventType", "timestamp");

-- CreateIndex
CREATE INDEX "events_triggerSource_timestamp_idx" ON "events"("triggerSource", "timestamp");

-- CreateIndex
CREATE INDEX "_UserRoles_B_index" ON "_UserRoles"("B");

-- AddForeignKey
ALTER TABLE "accounts" ADD CONSTRAINT "accounts_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sessions" ADD CONSTRAINT "sessions_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "businesses" ADD CONSTRAINT "businesses_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "roles" ADD CONSTRAINT "roles_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "business_users" ADD CONSTRAINT "business_users_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "business_users" ADD CONSTRAINT "business_users_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "business_users" ADD CONSTRAINT "business_users_roleId_fkey" FOREIGN KEY ("roleId") REFERENCES "roles"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ai_agents" ADD CONSTRAINT "ai_agents_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ai_agents" ADD CONSTRAINT "ai_agents_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "agent_calls" ADD CONSTRAINT "agent_calls_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "agent_calls" ADD CONSTRAINT "agent_calls_agentId_fkey" FOREIGN KEY ("agentId") REFERENCES "ai_agents"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "api_keys" ADD CONSTRAINT "api_keys_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "api_keys" ADD CONSTRAINT "api_keys_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "api_usage" ADD CONSTRAINT "api_usage_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "api_usage" ADD CONSTRAINT "api_usage_apiKeyId_fkey" FOREIGN KEY ("apiKeyId") REFERENCES "api_keys"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "integrations" ADD CONSTRAINT "integrations_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tickets" ADD CONSTRAINT "tickets_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tickets" ADD CONSTRAINT "tickets_agentCallId_fkey" FOREIGN KEY ("agentCallId") REFERENCES "agent_calls"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tickets" ADD CONSTRAINT "tickets_raisedById_fkey" FOREIGN KEY ("raisedById") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tickets" ADD CONSTRAINT "tickets_assignedToId_fkey" FOREIGN KEY ("assignedToId") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "schedules" ADD CONSTRAINT "schedules_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "schedules" ADD CONSTRAINT "schedules_agentCallId_fkey" FOREIGN KEY ("agentCallId") REFERENCES "agent_calls"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "schedules" ADD CONSTRAINT "schedules_scheduledById_fkey" FOREIGN KEY ("scheduledById") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "email_logs" ADD CONSTRAINT "email_logs_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "email_logs" ADD CONSTRAINT "email_logs_agentCallId_fkey" FOREIGN KEY ("agentCallId") REFERENCES "agent_calls"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "email_logs" ADD CONSTRAINT "email_logs_sentById_fkey" FOREIGN KEY ("sentById") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "text_message_logs" ADD CONSTRAINT "text_message_logs_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "text_message_logs" ADD CONSTRAINT "text_message_logs_agentCallId_fkey" FOREIGN KEY ("agentCallId") REFERENCES "agent_calls"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "text_message_logs" ADD CONSTRAINT "text_message_logs_sentById_fkey" FOREIGN KEY ("sentById") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "whatsapp_messages" ADD CONSTRAINT "whatsapp_messages_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "whatsapp_messages" ADD CONSTRAINT "whatsapp_messages_agentCallId_fkey" FOREIGN KEY ("agentCallId") REFERENCES "agent_calls"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "whatsapp_messages" ADD CONSTRAINT "whatsapp_messages_sentById_fkey" FOREIGN KEY ("sentById") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "audit_logs" ADD CONSTRAINT "audit_logs_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "data_retention_policies" ADD CONSTRAINT "data_retention_policies_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "quality_metrics" ADD CONSTRAINT "quality_metrics_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "quality_metrics" ADD CONSTRAINT "quality_metrics_agentId_fkey" FOREIGN KEY ("agentId") REFERENCES "ai_agents"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "quality_metrics" ADD CONSTRAINT "quality_metrics_callId_fkey" FOREIGN KEY ("callId") REFERENCES "agent_calls"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "events" ADD CONSTRAINT "events_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "events" ADD CONSTRAINT "events_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "businesses"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_UserRoles" ADD CONSTRAINT "_UserRoles_A_fkey" FOREIGN KEY ("A") REFERENCES "roles"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_UserRoles" ADD CONSTRAINT "_UserRoles_B_fkey" FOREIGN KEY ("B") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
