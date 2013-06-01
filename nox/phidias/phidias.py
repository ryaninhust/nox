import math

import dpark


class SplitCiterion(object):
    pass


class GiniCiterion(SplitCiterion):

    """
    Gini 2p(1-p)
    """
    def __call__(self, item_count, total_count):
        prob = float(item_count) / total_count
        return 2 * prob * (1.0 - prob)


class CrossEncropyCiterion(SplitCiterion):

    """
    CrossEncropy -plog(p) - (1-p)log(1-p)
    """
    def __call__(self, item_count, total_count):
        prob = float(item_count) / total_count
        return -prob * math.log(prob) - (1 - prob) * math.log(1 - prob)


def get_phidias_point(feature_set, citerion=CrossEncropyCiterion):
    """
    through all feature_set to find
    a best split citerion
    """
    feature_rdd = dpark.parallelize(feature_set)
    total_count = feature_rdd.count()

    def _label_count(item):
        return (item, 1)

    def _count_stat(item):
        return (item[0], sum(item[1]))

    def _compute_criterion(item):
        return (item[0], citerion()(item[1], total_count))

    def _max_criterion(item1, item2):
        return item1 if item1[1] > item2[1] else item2

    return feature_rdd.map(_label_count).groupByKey().map(_count_stat).map(_compute_criterion).collect()

if __name__ == "__main__":
    a = ['a', 'b', 'c', 'd', 'e', 'a', 'a']
    print get_phidias_point(a)
