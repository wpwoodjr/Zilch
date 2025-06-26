#define m_tx_address(bu, x) \
      (x + bu_base(bu) + (x + bu_base(bu) >= bu_gap(bu) ? bu_gap_size(bu) : 0))
