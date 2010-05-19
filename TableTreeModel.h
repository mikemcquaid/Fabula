/*  This file is part of Fabula.
    Copyright (C) 2010 Mike Arthur <mike@mikearthur.co.uk>

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

#ifndef TABLETREEMODEL_H
#define TABLETREEMODEL_H

#include <QAbstractItemModel>
#include <QStringList>

class SqlTreeItem
{
public:
    static const qint64 INVALID_ID = -1;

    SqlTreeItem(const QString &data, const QString &table = QString(), SqlTreeItem *parent = 0, qint64 id = INVALID_ID);
    ~SqlTreeItem();

    SqlTreeItem *child(int row);
    void appendChild(SqlTreeItem* child);
    int childCount() const;
    const QString &table() const;
    const QString &data() const;
    int row() const;
    SqlTreeItem *parent();
    void setData(const QString &value);
    qint64 id() const;
    void setId(qint64 id);
    bool dirty() const;
    void setDirty(bool dirty);
    const QList<SqlTreeItem*>& children() const;

private:
    QList<SqlTreeItem*> m_children;
    QString m_table;
    QString m_data;
    SqlTreeItem *m_parent;
    int m_id;
    bool m_dirty;
};

class SqlTreeModel : public QAbstractItemModel
{
    Q_OBJECT

public:
    SqlTreeModel(QObject *parent = 0);
    ~SqlTreeModel();

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;
    bool setData(const QModelIndex &index, const QVariant &value, int role);
    Qt::ItemFlags flags(const QModelIndex &index) const;
    QVariant headerData(int section, Qt::Orientation orientation,
                        int role = Qt::DisplayRole) const;
    QModelIndex index(int row, int column,
                      const QModelIndex &parent = QModelIndex()) const;
    QModelIndex parent(const QModelIndex &index) const;
    int rowCount(const QModelIndex &parent = QModelIndex()) const;
    int columnCount(const QModelIndex &parent = QModelIndex()) const;
    bool insertRow(int row, const QModelIndex &parent = QModelIndex());
    bool submit();
    void reset();

signals:
    void submitted();

private:
    void loadData();
    QString getChildTable(const QString& parentTable);
    SqlTreeItem *m_rootItem;
    QStringList tables;
};

#endif // TABLETREEMODEL_H
