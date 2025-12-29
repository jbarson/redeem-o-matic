// Structured logging service for the application
// Provides consistent logging with levels and can be extended to send logs to external services

type LogLevel = 'debug' | 'info' | 'warn' | 'error';

interface LogContext {
  [key: string]: unknown;
}

class Logger {
  private isDevelopment = process.env.NODE_ENV === 'development';
  private appName = 'Redeem-O-Matic';

  /**
   * Format log message with timestamp and metadata
   */
  private formatMessage(level: LogLevel, message: string, context?: LogContext): string {
    const timestamp = new Date().toISOString();
    const contextStr = context ? JSON.stringify(context, null, 2) : '';
    return `[${timestamp}] [${this.appName}] [${level.toUpperCase()}] ${message}${contextStr ? '\n' + contextStr : ''}`;
  }

  /**
   * Send logs to external monitoring service (placeholder)
   * In production, integrate with services like Sentry, DataDog, etc.
   */
  private sendToMonitoring(level: LogLevel, message: string, context?: LogContext): void {
    // Placeholder for external logging service integration
    // Example: Sentry.captureMessage(message, { level, extra: context });

    // For now, just log to console in production
    if (!this.isDevelopment) {
      const formatted = this.formatMessage(level, message, context);
      console.log(formatted);
    }
  }

  /**
   * Debug level logging - only in development
   */
  debug(message: string, context?: LogContext): void {
    if (this.isDevelopment) {
      console.debug(this.formatMessage('debug', message, context));
    }
  }

  /**
   * Info level logging
   */
  info(message: string, context?: LogContext): void {
    if (this.isDevelopment) {
      console.info(this.formatMessage('info', message, context));
    } else {
      this.sendToMonitoring('info', message, context);
    }
  }

  /**
   * Warning level logging
   */
  warn(message: string, context?: LogContext): void {
    if (this.isDevelopment) {
      console.warn(this.formatMessage('warn', message, context));
    } else {
      this.sendToMonitoring('warn', message, context);
    }
  }

  /**
   * Error level logging
   */
  error(message: string, error?: Error | unknown, context?: LogContext): void {
    const errorContext: LogContext = {
      ...context,
      error: error instanceof Error ? {
        name: error.name,
        message: error.message,
        stack: error.stack,
      } : error,
    };

    if (this.isDevelopment) {
      console.error(this.formatMessage('error', message, errorContext));
      if (error instanceof Error) {
        console.error(error);
      }
    } else {
      this.sendToMonitoring('error', message, errorContext);
    }
  }

  /**
   * Log API errors specifically
   */
  apiError(endpoint: string, error: unknown, context?: LogContext): void {
    this.error(`API Error: ${endpoint}`, error, {
      ...context,
      endpoint,
      timestamp: new Date().toISOString(),
    });
  }

  /**
   * Log user actions for analytics
   */
  userAction(action: string, context?: LogContext): void {
    this.info(`User Action: ${action}`, {
      ...context,
      action,
      timestamp: new Date().toISOString(),
    });
  }
}

// Export singleton instance
export const logger = new Logger();
