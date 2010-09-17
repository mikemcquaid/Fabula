/*  This file is part of Fabula.
    Copyright (C) 2010 Mike McQuaid <mike@mikemcquaid.com>

    Fabula is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Fabula is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Fabula. If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef TWOROWDELEGATE_H
#define TWOROWDELEGATE_H

#include <QSqlRelationalDelegate>

class QAbstractItemView;

class TwoRowDelegate : public QSqlRelationalDelegate
{
    Q_OBJECT
public:
    explicit TwoRowDelegate(int secondRowColumn, QAbstractItemView *view, QObject *parent = 0);
    virtual void paint(QPainter *painter, const QStyleOptionViewItem &option, const QModelIndex &index) const;
    virtual QSize sizeHint(const QStyleOptionViewItem &option, const QModelIndex &index) const;
private:
    QSize firstRowSizeHint(const QStyleOptionViewItem &option, const QModelIndex &index) const;
    int secondRowHeight(const QStyleOptionViewItem &option, const QModelIndex &index) const;
    QModelIndex secondRowIndex(const QModelIndex &index) const;
    void updateEditorGeometry(QWidget *editor, const QStyleOptionViewItem &option, const QModelIndex &index) const;
    bool editorEvent(QEvent *event, QAbstractItemModel *model, const QStyleOptionViewItem &option, const QModelIndex &index);
    const int m_column;
    const QAbstractItemView *m_view;
};

#endif // TWOROWDELEGATE_H