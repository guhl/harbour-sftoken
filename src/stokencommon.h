/*
  Copyright (C) 2017 Guhl.
  Contact: Guhl <guhl@dershampoonierte.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#ifndef STOKENCOMMON_H
#define STOKENCOMMON_H

extern "C" {
#include "common.h"
#include "securid.h"
#include "stoken.h"
#include "stoken-internal.h"
}

#include <ctype.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include <QObject>
#include <QDateTime>
#include <QUrl>
#include <sstream>
#include <string>

class StokenCommon : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString err_string READ err_string)
    Q_PROPERTY(qint16 token_days_left READ token_days_left WRITE setToken_days_left NOTIFY token_days_leftChanged)
    Q_PROPERTY(qint16 token_interval READ token_interval WRITE setToken_interval)
    Q_PROPERTY(QString token_string READ token_string WRITE setToken_string NOTIFY token_stringChanged)
    Q_PROPERTY(QString next_token_string READ next_token_string WRITE setNext_token_string NOTIFY next_token_stringChanged)
    Q_PROPERTY(QString pin READ pin WRITE setPin)
    Q_PROPERTY(QString token_serial READ token_serial)
    Q_PROPERTY(QString expiration_date READ expiration_date)
    Q_PROPERTY(bool token_uses_pin READ token_uses_pin)
    Q_PROPERTY(bool initialized READ initialized)
public:
    explicit StokenCommon(QObject *parent = 0);

    qint16 token_days_left() const { return m_token_days_left; }
    void setToken_days_left(const qint16 &d);

    qint16 token_interval() const { return m_token_interval; }
    void setToken_interval(const qint16 &d) { m_token_interval = d; }

    bool token_uses_pin() { return (m_token_uses_pin == 1) ? true : false; }
    void setToken_uses_pin(const qint16 &d) { m_token_uses_pin = d; }

    QString err_string() const { return m_err_string; }

    QString token_string();
    void setToken_string(const QString &token_string);

    QString next_token_string();
    void setNext_token_string(const QString &next_token_string);

    QString pin() const { return m_pin; }
    void setPin(const QString &pin);

    bool initialized() const { return m_initialized; }

    QString token_serial() const { return m_token_serial; }
    QString expiration_date() const { return m_expiration_date; }

    Q_INVOKABLE bool importToken(const QString& f);
    Q_INVOKABLE void token_init();

signals:
    void token_days_leftChanged();
    void token_stringChanged();
    void next_token_stringChanged();
private:
    struct stoken_cfg* m_cfg;
    struct securid_token* m_current_token;
    bool m_initialized;
    qint16 m_token_days_left;
    qint16 m_token_interval;
    qint16 m_token_uses_pin;
    QString m_err_string;
    QString m_token_string;
    QString m_next_token_string;
    QString m_pin;
    QString m_token_serial;
    QString m_expiration_date;

    char *xstrdup(const char *s);
    void xstrncpy(char *dest, const char *src, size_t n);
    void *xmalloc(size_t size);
    void *xzalloc(size_t size);
    int decode_rc_token(struct stoken_cfg *cfg, struct securid_token *t);
    int common_init();
    time_t adjusted_time(struct securid_token *t, int opt_next, long opt_use_time);
    void securid_token_info(const struct securid_token *t);
    int read_token_from_file(char *filename, struct securid_token *t);
    int write_token_and_pin(char *token_str, char *pin_str, char *password);

public slots:
};

#endif // STOKENCOMMON_H
