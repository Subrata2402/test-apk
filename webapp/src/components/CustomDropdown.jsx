import React, { useState, useRef, useEffect } from 'react';
import * as Icons from 'lucide-react';
import './CustomDropdown.css';

export default function CustomDropdown({ options, value, onChange, placeholder = 'Select option' }) {
  const [isOpen, setIsOpen] = useState(false);
  const dropdownRef = useRef(null);

  // Close dropdown when clicking outside
  useEffect(() => {
    function handleClickOutside(event) {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target)) {
        setIsOpen(false);
      }
    }
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  // Format options to always be objects { value, label, icon }
  const formattedOptions = options.map(opt => {
    if (typeof opt === 'string') {
      return { value: opt, label: opt };
    }
    return opt;
  });

  const selectedOption = formattedOptions.find(opt => opt.value === value) || { value, label: value || placeholder };
  const SelectedIcon = selectedOption.icon ? Icons[selectedOption.icon] : null;

  return (
    <div className="custom-dropdown" ref={dropdownRef}>
      <button
        type="button"
        className={`dropdown-trigger ${isOpen ? 'open' : ''}`}
        onClick={() => setIsOpen(!isOpen)}
      >
        <div className="trigger-content">
          {SelectedIcon && <SelectedIcon size={16} className="dropdown-item-icon" />}
          <span>{selectedOption.label}</span>
        </div>
        <Icons.ChevronDown size={16} className={`dropdown-arrow ${isOpen ? 'open' : ''}`} />
      </button>

      {isOpen && (
        <div className="dropdown-menu animate-fade-in">
          {formattedOptions.map((opt) => {
            const ItemIcon = opt.icon ? Icons[opt.icon] : null;
            const isSelected = opt.value === value;
            return (
              <button
                key={opt.value}
                type="button"
                className={`dropdown-item ${isSelected ? 'selected' : ''}`}
                onClick={() => {
                  onChange(opt.value);
                  setIsOpen(false);
                }}
              >
                {ItemIcon && <ItemIcon size={16} className="dropdown-item-icon" />}
                <span>{opt.label}</span>
                {isSelected && <Icons.Check size={14} className="check-icon" />}
              </button>
            );
          })}
        </div>
      )}
    </div>
  );
}
